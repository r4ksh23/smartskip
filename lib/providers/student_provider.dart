import '../models/student.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];

  List<Student> get students => _students;

  Future<void> loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final studentData = prefs.getString('students');
    if (studentData != null) {
      final List decoded = jsonDecode(studentData);
      _students = decoded.map((e) => Student.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addStudent(String name) async {
    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
    );
    _students.add(newStudent);
    await saveStudents();
    notifyListeners();
  }

  Future<void> markBunk(int studentId) async {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index].bunks += 1;
      await saveStudents();
      notifyListeners();
    }
  }

  Future<void> saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_students.map((e) => e.toJson()).toList());
    await prefs.setString('students', encoded);
  }
}
