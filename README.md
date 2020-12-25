# student_service

Bài Tập Thực Hành Flutter

MSV: 1621050434
Tên: Lê Nhật Dương

## Introduction:

Sử Dụng sqlite để thêm sửa xóa và hiển thị sinh viên.

## Screenshots

132004966_412189506890530_1775563343967046197_n.png
132523962_691407461743779_6906690559263735984_n.png
132562518_2780089225562309_4054351207760436166_n.png
132997992_683755218962404_5597828454152985440_n.png
133148095_249065693250065_622554275000390985_n.png

## Code:

Model: Student.dart
           
          class Student {
          int id;
          String name;
          Student(this.id, this.name);
        
          Map<String, dynamic> toMap() {
            var map = <String, dynamic>{
              'id': id,
              'name': name
            };
            return map;
          }
        
          Student.fromMap(Map<String, dynamic> map) {
            id = map['id'];
            name = map['name'];
          }
        }
Repository: StudentRepository.dart
        
        abstract class StudentRepository {
          Future<Student> add(Student student);
          Future<List<Student>> getStudents();
          Future<int> delete(int id);
          Future<int> update(Student student);
          Future close();
        }
Service: StudentService.dart
        
          class StudentService with StudentRepository {
          static Database _db;
          Future<Database> get db async {
            if (_db != null) {
              return _db;
            }
            _db = await initDatabase();
            return _db;
          }
        
          initDatabase() async {
            io.Directory documentDirectory = await getApplicationDocumentsDirectory();
            String path = join(documentDirectory.path, 'student.db');
            var db = await openDatabase(path, version: 1, onCreate: _onCreate);
            return db;
          }
        
          _onCreate(Database db, int version) async {
            await db
                .execute('CREATE TABLE student (id INTEGER PRIMARY KEY, name TEXT)');
          }
        
          Future<Student> add(Student student) async {
            var dbClient = await db;
            student.id = await dbClient.insert('student', student.toMap());
            return student;
          }
        
          Future<List<Student>> getStudents() async {
            var dbClient = await db;
            List<Map> maps = await dbClient.query('student', columns: ['id', 'name']);
            List<Student> students = [];
            if (maps.length > 0) {
              for (int i = 0; i < maps.length; i++) {
                students.add(Student.fromMap(maps[i]));
              }
            }
            return students;
          }
        
          Future<int> delete(int id) async {
            var dbClient = await db;
            return await dbClient.delete(
              'student',
              where: 'id = ?',
              whereArgs: [id],
            );
          }
        
          Future<int> update(Student student) async {
            var dbClient = await db;
            return await dbClient.update(
              'student',
              student.toMap(),
              where: 'id = ?',
              whereArgs: [student.id],
            );
          }
        
          Future close() async {
            var dbClient = await db;
            dbClient.close();
          }
        }       
Main: 

        void main() => runApp(MyApp());
        
        class MyApp extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.indigo,
              ),
              home: StudentPage(),
            );
          }
        }
        
        class StudentPage extends StatefulWidget {
          @override
          _StudentPageState createState() => _StudentPageState();
        }
        
        class _StudentPageState extends State<StudentPage> {
          final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
          Future<List<Student>> students;
          String _studentName;
          bool isUpdate = false;
          int studentIdForUpdate;
          StudentService studentService;
          final _studentNameController = TextEditingController();
        
          @override
          void initState() {
            super.initState();
            studentService = StudentService();
            refreshStudentList();
          }
        
          refreshStudentList() {
            setState(() {
              students = studentService.getStudents();
            });
          }
        
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Duong App'),
              ),
              body: Column(
                children: <Widget>[
                  Form(
                    key: _formStateKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Student Name';
                              }
                              if (value.trim() == "")
                                return "Only Space is Not Valid!!!";
                              return null;
                            },
                            onSaved: (value) {
                              _studentName = value;
                            },
                            controller: _studentNameController,
                            decoration: InputDecoration(
                                focusedBorder: new UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.black38,
                                        width: 2,
                                        style: BorderStyle.solid)),
                                // hintText: "Student Name",
                                labelText: "Student Name",
                                icon: Icon(
                                  Icons.business_center,
                                  color: Colors.black38,
                                ),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: Colors.blue,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.blueAccent,
                        child: Text(
                          (isUpdate ? 'UPDATE' : 'ADD'),
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (isUpdate) {
                            if (_formStateKey.currentState.validate()) {
                              _formStateKey.currentState.save();
                              studentService
                                  .update(Student(studentIdForUpdate, _studentName))
                                  .then((data) {
                                setState(() {
                                  isUpdate = false;
                                });
                              });
                            }
                          } else {
                            if (_formStateKey.currentState.validate()) {
                              _formStateKey.currentState.save();
                              studentService.add(Student(null, _studentName));
                            }
                          }
                          _studentNameController.text = '';
                          refreshStudentList();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                      ),
                      RaisedButton(
                        color: Colors.red,
                        child: Text(
                          (isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _studentNameController.text = '';
                          setState(() {
                            isUpdate = false;
                            studentIdForUpdate = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(
                    height: 5.0,
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: students,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return generateList(snapshot.data);
                        }
                        if (snapshot.data == null || snapshot.data.length == 0) {
                          return Text('No Data Found');
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        
          SingleChildScrollView generateList(List<Student> students) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text('NAME'),
                    ),
                    DataColumn(
                      label: Text('DELETE'),
                    )
                  ],
                  rows: students
                      .map(
                        (student) => DataRow(
                      cells: [
                        DataCell(
                          Text(student.name),
                          onTap: () {
                            setState(() {
                              isUpdate = true;
                              studentIdForUpdate = student.id;
                            });
                            _studentNameController.text = student.name;
                          },
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              studentService.delete(student.id);
                              refreshStudentList();
                            },
                          ),
                        )
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            );
          }
        }
