// This file also exports the utility function isSafeToBunk()

/// Returns true if it's safe to bunk (attendance >= 75%) for the given subject.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subject_screen.dart';
import 'calendar_screen.dart';
import 'timetable_screen.dart';
import 'dart:convert';

Future<bool> isSafeToBunk(String subjectName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final savedSubjects = prefs.getStringList('subjects');
  if (savedSubjects == null) return false;

  for (var s in savedSubjects) {
    final data = json.decode(s);
    if (data['subject'] == subjectName) {
      final present = data['present'] ?? 0;
      final bunked = data['bunked'] ?? 0;
      final total = present + bunked;
      if (total == 0) return false;
      final percentage = (present / total) * 100;
      return percentage >= 75;
    }
  }

  return false;
}

class SubjectAttendance {
  String subject;
  int present;
  int bunked;
  double requiredPercentage;

  SubjectAttendance({
    required this.subject,
    this.present = 0,
    this.bunked = 0,
    this.requiredPercentage = 75.0,
  });

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      subject: json['subject'],
      present: json['present'] ?? 0,
      bunked: json['bunked'] ?? 0,
      requiredPercentage: json['requiredPercentage'] ?? 75.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'present': present,
      'bunked': bunked,
      'requiredPercentage': requiredPercentage,
    };
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  List<SubjectAttendance> subjects = [];
  String selectedSubject = '';

  int get presentCount {
    final subject = subjects.firstWhere(
      (s) => s.subject == selectedSubject,
      orElse: () => SubjectAttendance(subject: selectedSubject),
    );
    return subject.present;
  }

  int get bunkedCount {
    final subject = subjects.firstWhere(
      (s) => s.subject == selectedSubject,
      orElse: () => SubjectAttendance(subject: selectedSubject),
    );
    return subject.bunked;
  }

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  void loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedSubjects = prefs.getStringList('subjects');
    if (savedSubjects != null) {
      subjects = savedSubjects
          .map((s) => SubjectAttendance.fromJson(json.decode(s)))
          .toList();

      if (subjects.isNotEmpty) {
        if (!subjects.any((s) => s.subject == selectedSubject)) {
          selectedSubject = subjects[0].subject;
        }
      }
      setState(() {});
    }
  }

  void saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedSubjects = subjects
        .map((s) => json.encode(s.toJson()))
        .toList();
    await prefs.setStringList('subjects', encodedSubjects);
  }

  void markPresent() {
    final index = subjects.indexWhere((s) => s.subject == selectedSubject);
    if (index != -1) {
      setState(() {
        subjects[index].present++;
      });
      saveSubjects();
    }
  }

  void markBunked() {
    final index = subjects.indexWhere((s) => s.subject == selectedSubject);
    if (index != -1) {
      setState(() {
        subjects[index].bunked++;
      });
      saveSubjects();
    }
  }

  void resetAttendance() {
    final index = subjects.indexWhere((s) => s.subject == selectedSubject);
    if (index != -1) {
      setState(() {
        subjects[index].present = 0;
        subjects[index].bunked = 0;
      });
      saveSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = presentCount + bunkedCount;
    final double percentage = total == 0 ? 0 : (presentCount / total * 100);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('SmartSkip', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
        toolbarOpacity: 1.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: Colors.grey[850],
            onSelected: (value) async {
              if (value == 'reset') {
                resetAttendance();
              } else if (value == 'manage') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubjectScreen(),
                  ),
                );

                await Future.sync(() => loadSubjects());

                if (subjects.isNotEmpty) {
                  if (!subjects.any((s) => s.subject == selectedSubject)) {
                    selectedSubject = subjects.first.subject;
                  }
                  setState(() {});
                } else {
                  selectedSubject = '';
                  setState(() {});
                }
              } else if (value == 'calendar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              } else if (value == 'timetable') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimetableScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.white),
                  title: const Text(
                    'Reset Attendance',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'manage',
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.white),
                  title: const Text(
                    'Manage Subjects',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'calendar',
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Calendar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'timetable',
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.white),
                  title: const Text(
                    'Timetable',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Subject:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = subject.subject == selectedSubject;

                  return Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: InputChip(
                      label: Text(
                        subject.subject,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.grey[900]
                              : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.grey[300],
                      selectedColor: Colors.grey[500],
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedSubject = subject.subject;
                        });
                      },
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: markPresent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 28,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Present',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: markBunked,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bunked',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (selectedSubject.isNotEmpty && total != 0) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      selectedSubject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Attendance: ${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Actual attendance pie ring using CustomPaint
                          CustomPaint(
                            size: const Size(160, 160),
                            painter: RingPainter(
                              present: presentCount,
                              bunked: bunkedCount,
                            ),
                          ),
                          // Percentage text
                          Text(
                            "${percentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard(
                                "Attended",
                                presentCount,
                                Colors.green,
                                Icons.check_circle,
                              ),
                              _buildStatCard(
                                "Bunked",
                                bunkedCount,
                                Colors.red,
                                Icons.cancel,
                              ),
                              _buildStatCard(
                                "Total",
                                total,
                                Colors.blueGrey,
                                Icons.equalizer,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final subject = subjects.firstWhere(
                                (s) => s.subject == selectedSubject,
                              );
                              final required = subject.requiredPercentage == 0
                                  ? 0.75
                                  : subject.requiredPercentage / 100;
                              final needToAttend =
                                  ((required * total - presentCount) /
                                          (1 - required))
                                      .ceil();
                              final canStillBunk =
                                  ((presentCount / required) - total).floor();

                              return Card(
                                margin: const EdgeInsets.only(top: 10),
                                color: Colors.grey[850],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        needToAttend > 0
                                            ? "Attend $needToAttend more class${needToAttend == 1 ? '' : 'es'} to reach ${subject.requiredPercentage.toStringAsFixed(0)}%"
                                            : canStillBunk >= 1
                                            ? "You can bunk $canStillBunk more class${canStillBunk == 1 ? '' : 'es'} and stay above ${subject.requiredPercentage.toStringAsFixed(0)}%"
                                            : "❌ Not safe to bunk right now. Attend more classes!",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              const Center(
                child: Text(
                  "No attendance data yet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatCard(String label, int value, Color color, IconData icon) {
  return SizedBox(
    width: 100, // fixed width for uniformity
    child: Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}

class RingPainter extends CustomPainter {
  final int present;
  final int bunked;

  RingPainter({required this.present, required this.bunked});

  @override
  void paint(Canvas canvas, Size size) {
    final total = present + bunked;
    if (total == 0) return;

    final presentSweep = (present / total) * 360;
    final bunkedSweep = 360 - presentSweep;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * 0.0174533, // Start angle in radians
      presentSweep * 0.0174533,
      false,
      paint,
    );

    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      (-90 + presentSweep) * 0.0174533,
      bunkedSweep * 0.0174533,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
