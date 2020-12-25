import 'package:student_service/models/Student.dart';

abstract class StudentRepository {
  Future<Student> add(Student student);
  Future<List<Student>> getStudents();
  Future<int> delete(int id);
  Future<int> update(Student student);
  Future close();
}