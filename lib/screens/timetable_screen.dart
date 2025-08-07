import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// Updated: Attendance logic with bunkable class check
Future<Map<String, dynamic>> isSafeToBunk(String subject) async {
  final prefs = await SharedPreferences.getInstance();
  final savedSubjects = prefs.getStringList('subjects');
  if (savedSubjects != null) {
    for (var s in savedSubjects) {
      final data = json.decode(s);
      if (data['subject'] == subject) {
        final present = data['present'] ?? 0;
        final bunked = data['bunked'] ?? 0;
        final total = present + bunked;
        final required = (data['requiredPercentage'] ?? 75).toDouble();

        if (total == 0) return {'safe': false, 'required': required};

        final effectivePresent = present.toDouble();
        int extraBunks = 0;

        while (true) {
          final newTotal = total + extraBunks + 1;
          final newPercent = (effectivePresent / newTotal) * 100;
          if (newPercent < required) break;
          extraBunks++;
        }

        return {'safe': extraBunks >= 1, 'required': required};
      }
    }
  }
  return {'safe': false, 'required': 75.0};
}
// import 'package:intl/intl.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Map<String, List<Map<String, String>>> timetable = {};
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String selectedDay = 'Monday';
  String subject = '';
  String time = '';

  Timer? _timer;
  TimeOfDay _currentTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    loadTimetable();
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      setState(() {
        _currentTime = TimeOfDay.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isCurrentPeriod(String timeRange) {
    try {
      final parts = timeRange.split('-');
      if (parts.length != 2) return false;

      parseTime(String t) {
        final trimmed = t.trim();
        final timeOfDay = TimeOfDay(
          hour: int.parse(trimmed.split(":")[0]),
          minute: int.parse(trimmed.split(":")[1].split(" ")[0]),
        );
        return DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
      }

      final now = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _currentTime.hour,
        _currentTime.minute,
      );
      final start = parseTime(parts[0]);
      final end = parseTime(parts[1]);

      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }

  void loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('timetable');
    if (jsonString != null) {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      setState(() {
        for (var key in decoded.keys) {
          timetable[key] = List<Map<String, String>>.from(
            (decoded[key] as List).map((e) => Map<String, String>.from(e)),
          );
        }
      });
    }
  }

  void saveTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(timetable);
    await prefs.setString('timetable', encoded);
  }

  void addEntry() {
    if (subject.isEmpty || time.isEmpty) return;
    timetable[selectedDay] = timetable[selectedDay] ?? [];
    timetable[selectedDay]!.add({'subject': subject, 'time': time});
    saveTimetable();
    setState(() {
      subject = '';
      time = '';
    });
  }

  void deleteEntry(int index) {
    timetable[selectedDay]!.removeAt(index);
    saveTimetable();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = timetable[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('📅 Timetable Setup'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(137, 255, 255, 255),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: days.map((day) {
                  final isSelected = day == selectedDay;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      selectedColor: Colors.grey[800],
                      backgroundColor: Colors.grey[300],
                      shadowColor: Colors.transparent,
                      selectedShadowColor: Colors.transparent,
                      side: BorderSide(color: Colors.transparent),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                fillColor: Color(0xFF2C2C2E),
                filled: true,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (val) => subject = val,
              controller: TextEditingController(text: subject),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final TimeOfDay? start = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.grey[800]!,
                                onPrimary: Colors.white,
                                surface: Colors.grey[900]!,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (start != null) {
                        final TimeOfDay? end = await showTimePicker(
                          context: context,
                          initialTime: start,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.grey[800]!,
                                  onPrimary: Colors.white,
                                  surface: Colors.grey[900]!,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (end != null) {
                          setState(() {
                            time =
                                '${start.format(context)} - ${end.format(context)}';
                          });
                        }
                      }
                    },
                    child: Text(
                      time.isEmpty ? 'Select Period Time' : time,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: addEntry,
              child: const Text('Add to Timetable'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: entries.isEmpty
                  ? const Text('No entries yet.')
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final subject = entry['subject'] ?? '';
                        final time = entry['time'] ?? '';
                        final isActive = _isCurrentPeriod(time);

                        return FutureBuilder<Map<String, dynamic>>(
                          future: isSafeToBunk(subject),
                          builder: (context, snapshot) {
                            final safe = snapshot.data?['safe'] ?? false;
                            final required = snapshot.data?['required'] ?? 75.0;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                            255,
                                            143,
                                            143,
                                            143,
                                          ).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ListTile(
                                title: Text(subject),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(time),
                                    if (snapshot.connectionState ==
                                        ConnectionState.done)
                                      () {
                                        String message;
                                        Color messageColor;

                                        if (safe) {
                                          message = "✅ Safe to Bunk";
                                          messageColor = Colors.green;
                                        } else {
                                          message =
                                              "❌ Must Attend to stay above ${required.toStringAsFixed(0)}%";
                                          messageColor = Colors.red;
                                        }

                                        return Text(
                                          message,
                                          style: TextStyle(
                                            color: messageColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      }(),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteEntry(index),
                                ),
                              ),
                            );
                          },
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
