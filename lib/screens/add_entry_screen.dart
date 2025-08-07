import 'package:flutter/material.dart';

class AddEntryScreen extends StatefulWidget {
  final Function(int attended, int bunked) onSubmit;

  const AddEntryScreen({super.key, required this.onSubmit});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController attendedController = TextEditingController();
  final TextEditingController bunkedController = TextEditingController();

  void submit() {
    final attended = int.tryParse(attendedController.text);
    final bunked = int.tryParse(bunkedController.text);

    if (attended == null || bunked == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter valid numbers')));
      return;
    }

    widget.onSubmit(attended, bunked);
    Navigator.of(context).pop(); // Go back to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Attendance Entry")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: attendedController,
              decoration: InputDecoration(labelText: 'Classes Attended'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: bunkedController,
              decoration: InputDecoration(labelText: 'Classes Bunked'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: submit, child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}
