import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sametsalah/main.dart';

Future<void> requestPermissionNotification() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}
Future<void> fcmconfig() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle notification when the app is in the foreground
    // Show dialog or custom UI
    FlutterRingtonePlayer().playNotification();
    Get.defaultDialog(
      title: message.notification!.title!,
      titleStyle: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
      middleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      middleText: message.notification!.body!,
      backgroundColor: Colors.grey,
      actions: [
        MaterialButton(
          color: Colors.grey,
          onPressed: () {
            Get.back();
          },
          child: Text(
            "Ok".tr,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  });
}