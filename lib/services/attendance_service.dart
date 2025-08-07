import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  static const String attendedKey = 'attended';
  static const String totalKey = 'total';

  Future<void> saveAttendance(int attended, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(attendedKey, attended);
    await prefs.setInt(totalKey, total);
  }

  Future<Map<String, int>> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attended = prefs.getInt(attendedKey) ?? 0;
    final total = prefs.getInt(totalKey) ?? 0;
    return {'attended': attended, 'total': total};
  }

  Future<void> resetAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(attendedKey);
    await prefs.remove(totalKey);
  }
}
