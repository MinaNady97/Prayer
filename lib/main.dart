import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/controllers/PrayerTimesStorage.dart';
import 'package:sametsalah/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

late var service;
final MainController controller = Get.put(MainController());
List<QueryDocumentSnapshot> constants = [];
late SharedPreferences instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await controller.initializeService();
  constants = controller.constants;
  instance = await SharedPreferences.getInstance();

  final now_ = DateTime.now();

  final String formattedDate =
      '${controller.addLeadingZero(now_.day)}-${controller.addLeadingZero(now_.month)}-${controller.addLeadingZero(now_.year)}';

  final List<dynamic>? storedPrayerTimes_ =
      await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

  if (storedPrayerTimes_ == null) {
    instance.clear();
    await controller.fetchPrayerTimingsForMonth();
  }
  // Call setupFirebaseMessaging to initialize Firebase Cloud Messaging
  controller.setupFirebaseMessaging();
  await controller.fetchPrayerTimings();
  runApp(MyApp());
}
