 import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/controllers/PrayerTimesStorage.dart';
import 'package:sametsalah/other/fbnotify.dart';
import 'package:sametsalah/other/firebase_options.dart';
import 'package:sametsalah/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

late var service;
final MainController controller = Get.put(MainController());
//List<QueryDocumentSnapshot> constants = [];
SharedPreferences? instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    // Initialize the shared preferences instance
    controller.instance = await SharedPreferences.getInstance();
  } catch (e) {
    // Handle any exceptions that occur during initialization
    print('Error initializing SharedPreferences: $e');
    // You might want to handle this error gracefully, depending on your use case
    return;
  }
  await controller.initializeService();
  //constants = controller.constants;
  controller.updateTime();
  final now_ = DateTime.now();

  final String formattedDate =
      '${controller.addLeadingZero(now_.day)}-${controller.addLeadingZero(now_.month)}-${controller.addLeadingZero(now_.year)}';

  final List<dynamic>? storedPrayerTimes_ =
      await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

  if (controller.instance != null) {
    final now_ = DateTime.now();
    final String formattedDate =
        '${controller.addLeadingZero(now_.day)}-${controller.addLeadingZero(now_.month)}-${controller.addLeadingZero(now_.year)}';

    final List<dynamic>? storedPrayerTimes_ =
        await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

    if (storedPrayerTimes_ == null) {
      controller.instance!.clear();
      await controller.fetchPrayerTimingsForMonth();
    }

    // Continue with the rest of your code...
  } else {
    print('SharedPreferences instance is null. Cannot proceed.');
    // You might want to handle this error gracefully, depending on your use case
    return;
  }

  // Call setupFirebaseMessaging to initialize Firebase Cloud Messaging
  controller.setupFirebaseMessaging();
  await controller.fetchPrayerTimings();
  await controller.get_times_from_DB();
  if (await controller.getTheme() == null) {
    instance!.setBool("isDark", false);
    controller.theme_value = "light";
  } else {
    controller.isDark = RxBool(await controller.getTheme());
    controller.theme_value = controller.isDark.isTrue ? "dark" : "light";
  }
  runApp(MyApp());
  await requestPermissionNotification();
  await controller.requestLocationPermission();
  await controller.stop_battary_obtimized();
  await controller.requestnotifyPermission();
}
