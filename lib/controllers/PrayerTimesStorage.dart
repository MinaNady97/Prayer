import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesStorage {
  static const _keyPrefix = 'prayer_times_';

  static Future<void> savePrayerTimesForDate(
      String date,
      List<String> prayerTimes,
      List<String> prayerTimes_iqama,
      List<String> prayerTimes_Jumuah,
      String dayName,
      String gregorianDate,
      String gregorianDateDisplay,
      String hijriDate,
      String first_date,
      String last_date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${(date)}';
    await prefs.setStringList(key, [
      ...prayerTimes,
      ...prayerTimes_iqama,
      dayName,
      gregorianDate,
      gregorianDateDisplay,
      hijriDate,
      ...prayerTimes_Jumuah,
      first_date,
      last_date
    ]);
  }

  static Future<List<dynamic>?> getPrayerTimesForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${date}';
    return prefs.getStringList(key);
  }

  static String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
