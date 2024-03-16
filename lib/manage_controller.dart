import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sametsalah/main.dart';

abstract class ManageController extends GetxController {}

class ManageControllerImp extends ManageController {
  late TextEditingController title_notification;
  late TextEditingController body_notification;
  late TextEditingController Fajr;
  late TextEditingController Dhuhr;
  late TextEditingController Asr;
  late TextEditingController Maghrib;
  late TextEditingController Isha;
  List<QueryDocumentSnapshot> constants = [];

  GlobalKey<FormState> form_notification_state = GlobalKey<FormState>();
  GlobalKey<FormState> form_time_state = GlobalKey<FormState>();
  loginfirebase() async {}
  @override
  void onInit() async {
    FirebaseMessaging.instance.unsubscribeFromTopic("users");
    constants = Get.arguments;
    title_notification = TextEditingController();
    body_notification = TextEditingController();
    Fajr = TextEditingController();
    Dhuhr = TextEditingController();
    Asr = TextEditingController();
    Maghrib = TextEditingController();
    Isha = TextEditingController();

    title_notification.text = "";
    body_notification.text = "";
    Fajr.text = constants[0]["times"]["Fajr"].toString();
    Dhuhr.text = constants[0]["times"]["Dhuhr"].toString();
    Asr.text = constants[0]["times"]["Asr"].toString();
    Maghrib.text = constants[0]["times"]["Maghrib"].toString();
    Isha.text = constants[0]["times"]["Isha"].toString();
    super.onInit();
  }

  sendnotificationanddio() async {
    if (form_notification_state.currentState!.validate()) {
      sendnotification();
      Get.snackbar(
        'Done', // Title of the snackbar
        'Notification Sent Successfully', // Message of the snackbar
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.grey[800], // Background color of the snackbar
        colorText: Colors.white, // Text color of the snackbar
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    title_notification.dispose();
    body_notification.dispose();
    Fajr.dispose();
    Dhuhr.dispose();
    Asr.dispose();
    Maghrib.dispose();
    Isha.dispose();
    super.dispose();
  }

  Future<void> sendnotification() async {
    final url = Uri.parse(constants[0]["url_api"]);
    final bodyData = {
      'topic': "users",
      'body': body_notification.text,
      'title': title_notification.text,
    };
    final response = await http.post(url, body: bodyData);
    if (response.statusCode == 200) {
      print('Request successful');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void> update_time() async {
    if (form_time_state.currentState!.validate()) {
      var newTimes = {
        'Fajr': int.parse(Fajr.text),
        'Dhuhr': int.parse(Dhuhr.text),
        'Asr': int.parse(Asr.text),
        'Maghrib': int.parse(Maghrib.text),
        'Isha': int.parse(Isha.text),
      };
      await constants[0].reference.update({
        'times': newTimes,
      });
      Get.snackbar(
        'Done', // Title of the snackbar
        'Times Saved Successfully', // Message of the snackbar
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.grey[800], // Background color of the snackbar
        colorText: Colors.white, // Text color of the snackbar
        duration: Duration(seconds: 3),
      );
    }
  }
}
