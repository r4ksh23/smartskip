import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class AddStudentScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  AddStudentScreen({super.key});

  void saveStudent(BuildContext context) {
    final name = nameController.text.trim();
    if (name.isNotEmpty) {
      Provider.of<StudentProvider>(context, listen: false).addStudent(name);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Student "$name" added!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveStudent(context),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
