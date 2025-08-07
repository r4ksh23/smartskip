import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalAttended = 0;
  int totalBunked = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalAttended = prefs.getInt('attended') ?? 0;
      totalBunked = prefs.getInt('bunked') ?? 0;
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attended', totalAttended);
    await prefs.setInt('bunked', totalBunked);
  }

  void addAttendanceEntry(int attended, int bunked) {
    setState(() {
      totalAttended += attended;
      totalBunked += bunked;
    });
    _saveData();
  }

  double get attendancePercentage {
    int total = totalAttended + totalBunked;
    if (total == 0) return 0.0;
    return (totalAttended / total) * 100;
  }

  void navigateToAddEntryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(onSubmit: addAttendanceEntry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartSkip Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text("Total Attended: $totalAttended"),
                subtitle: Text("Total Bunked: $totalBunked"),
                trailing: Text(
                  "${attendancePercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: attendancePercentage < 75
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: navigateToAddEntryScreen,
              icon: const Icon(Icons.add),
              label: const Text("Add Entry"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
