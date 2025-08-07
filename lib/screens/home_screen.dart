import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  int attended = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  void loadAttendance() async {
    final data = await _attendanceService.getAttendance();
    setState(() {
      attended = data['attended']!;
      total = data['total']!;
    });
  }

  double get percentage => total == 0 ? 0 : (attended / total) * 100;

  String get status {
    if (percentage >= 75) {
      final canBunk = ((attended / 0.75).floor() - total);
      return "You're safe! You can bunk $canBunk more class(es)";
    } else {
      final mustAttend = ((0.75 * total).ceil() - attended);
      return "You must attend $mustAttend class(es) to reach 75%";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartSkip"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Attendance Stats",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text("Attended: $attended", style: const TextStyle(fontSize: 20)),
            Text("Total: $total", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(
              "Percentage: ${percentage.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/input');
              },
              child: const Text("Update Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
