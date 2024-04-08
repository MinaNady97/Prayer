import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/controllers/PrayerTimesStorage.dart';
import 'package:sametsalah/other/fbnotify.dart';
import 'package:sametsalah/other/firebase_options.dart';
import 'package:sametsalah/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

var service = FlutterBackgroundService();
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
    instance = await SharedPreferences.getInstance();
  } catch (e) {
    // Handle any exceptions that occur during initialization
    print('Error initializing SharedPreferences: $e');
    // You might want to handle this error gracefully, depending on your use case
    return;
  }

  //constants = controller.constants;
  controller.updateTime();
  final now_ = DateTime.now();
  final String formattedDate =
      '${controller.addLeadingZero(now_.day)}-${controller.addLeadingZero(now_.month)}-${controller.addLeadingZero(now_.year)}';

  final List<dynamic>? storedPrayerTimes_ =
      await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

  if (instance != null) {
    final now_ = DateTime.now();
    final String formattedDate =
        '${controller.addLeadingZero(now_.day)}-${controller.addLeadingZero(now_.month)}-${controller.addLeadingZero(now_.year)}';

    final List<dynamic>? storedPrayerTimes_ =
        await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

    if (storedPrayerTimes_ == null) {
      instance!.clear();
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
  await controller.fetchPrayerTimings(formattedDate);
  await controller.unread_notification();

  if (await controller.getTheme() == null) {
    instance!.setBool("isDark", false);
    controller.theme_value = "light";
  } else {
    controller.isDark = RxBool(await controller.getTheme());
    controller.theme_value = controller.isDark.isTrue ? "dark" : "light";
  }
  if (await instance!.getBool("isRed") == null) {
    instance!.setBool("isRed", true);
    controller.theme_color = "red".obs;
    controller.isRed = true.obs;
  } else {
    controller.isRed = RxBool(await controller.getThemeColor());
    controller.theme_color.value = controller.isRed.isTrue ? "red" : "blue";
    controller.selectedSky = controller.isRed.isTrue ? Sky.red : Sky.blue;
    controller.primary_dark_color.value = controller.isRed.isTrue
        ? Color.fromARGB(255, 127, 41, 53)
        : Color.fromARGB(255, 1, 50, 90);
    controller.primary_light_color.value = controller.isRed.isTrue
        ? Color.fromARGB(255, 127, 41, 53)
        : Color.fromARGB(255, 1, 50, 90);
  }
  if (instance!.getBool("isNotification") == null) {
    instance!.setBool("isNotification", true);
    controller.isNotification.value = true;
  } else {
    controller.isNotification = RxBool(await controller.getNotificationVlaue());
  }
  //var c = await service.isRunning();
  controller.isRunning = await service.isRunning();
  controller.service_is_runing.value = controller.isRunning;
  print("service is ${controller.isRunning}");
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
  await requestPermissionNotification();
  await controller.requestLocationPermission();
  await controller.stop_battary_obtimized();
  await controller.requestnotifyPermission();
}
