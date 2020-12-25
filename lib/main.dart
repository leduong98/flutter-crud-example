import 'package:flutter/material.dart';
import 'services/StudentService.dart';

import 'models/Student.dart';

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