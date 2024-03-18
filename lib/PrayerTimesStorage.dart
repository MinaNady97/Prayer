import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PrayerTimesStorage {
  static const _keyPrefix = 'prayer_times_';

  static Future<void> savePrayerTimesForDate(String date, List<String> prayerTimes,
      String dayName, String gregorianDate, String gregorianDateDisplay, String hijriDate) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${(date)}';
    await prefs.setStringList(key, [
      ...prayerTimes,
      dayName,
      gregorianDate,
      gregorianDateDisplay,
      hijriDate,
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