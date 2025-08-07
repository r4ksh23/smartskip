import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import '../models/subject_attendance.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

final TextEditingController _presentController = TextEditingController();
final TextEditingController _bunkedController = TextEditingController();
final TextEditingController _requiredController = TextEditingController();

class _SubjectScreenState extends State<SubjectScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<SubjectAttendance> subjects = [];

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  void loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('subjects');
    if (data != null) {
      subjects = data
          .map((s) => SubjectAttendance.fromJson(json.decode(s)))
          .toList();
      setState(() {});
    }
  }

  void saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = subjects.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList('subjects', encoded);
  }

  void addSubject() {
    final name = _nameController.text.trim();
    final present = int.tryParse(_presentController.text.trim()) ?? 0;
    final bunked = int.tryParse(_bunkedController.text.trim()) ?? 0;
    double required = 75.0;
    final requiredText = _requiredController.text.trim();
    final parsed = double.tryParse(requiredText);
    if (parsed != null && parsed > 0 && parsed <= 100) {
      required = parsed;
    } else if (requiredText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid required % between 1 and 100"),
        ),
      );
      return;
    }

    if (name.isEmpty || subjects.any((s) => s.subject == name)) return;

    setState(() {
      subjects.add(
        SubjectAttendance(
          subject: name,
          present: present,
          bunked: bunked,
          requiredPercentage: required,
        ),
      );
      _nameController.clear();
      _presentController.clear();
      _bunkedController.clear();
      _requiredController.clear();
    });
    saveSubjects();
  }

  void editSubject(int index) {
    final subject = subjects[index];
    final TextEditingController nameCtrl = TextEditingController(
      text: subject.subject,
    );
    final TextEditingController percentCtrl = TextEditingController(
      text: subject.requiredPercentage.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          "Edit Subject",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Subject Name",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            TextField(
              controller: percentCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Required % (e.g. 75)",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              final percentText = percentCtrl.text.trim();
              double newPercent = 75.0;
              final parsed = double.tryParse(percentText);
              if (parsed != null && parsed > 0 && parsed <= 100) {
                newPercent = parsed;
              } else if (percentText.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter a valid required % between 1 and 100",
                    ),
                  ),
                );
                return;
              }

              if (newName.isNotEmpty &&
                  (newName == subject.subject ||
                      !subjects.any((s) => s.subject == newName))) {
                setState(() {
                  subjects[index].subject = newName;
                  subjects[index].requiredPercentage = newPercent;
                  saveSubjects();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteSubject(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          "Delete Subject",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${subjects[index].subject}'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                subjects.removeAt(index);
                saveSubjects();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Add Subject with Details",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            TextField(
              controller: _presentController,
              cursorColor: Colors.white,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Attended Classes',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            TextField(
              controller: _bunkedController,
              cursorColor: Colors.white,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Missed Classes',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            TextField(
              controller: _requiredController,
              cursorColor: Colors.white,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Required % (default 75)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Subject",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              onPressed: addSubject,
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 10),
            Expanded(
              child: subjects.isEmpty
                  ? const Center(
                      child: Text(
                        "No subjects added yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        return Dismissible(
                          key: Key(subject.subject),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2E),
                              title: const Text(
                                "Delete Subject",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                "Delete '${subject.subject}' permanently?",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (_) {
                            setState(() {
                              subjects.removeAt(index);
                              saveSubjects();
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Card(
                                color: Colors.white.withOpacity(0.1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    subject.subject,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    "Present: ${subject.present}, Bunked: ${subject.bunked}, Required: ${subject.requiredPercentage.toStringAsFixed(1)}%",
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, subject.subject);
                                  },
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () => editSubject(index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
