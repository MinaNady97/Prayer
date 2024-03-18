import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sametsalah/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

abstract class notification_controller extends GetxController {}

class notification_controllerImp extends notification_controller {
  StreamController<QuerySnapshot> _notificationsStreamController =
      StreamController<QuerySnapshot>.broadcast(); // Use a broadcast stream

  StreamSubscription<QuerySnapshot>?
      _streamSubscription; // Declare the stream subscription

  Stream<QuerySnapshot> get notificationsStream =>
      _notificationsStreamController.stream;

  @override
  void onInit() async {
    super.onInit(); // Call super.onInit() first
    await get_notifications_from_DB();
  }

  Stream<QuerySnapshot> get_notifications_from_DB() {
    // try {
    // Stream<QuerySnapshot> notifications_snapshot = await
    return FirebaseFirestore.instance
        .collection("notifications")
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Add the notifications to the stream
    //   _notificationsStreamController.add(notifications_snapshot);

    //   // Cancel any existing stream subscription
    //   _streamSubscription?.cancel();

    //   // Set up a new stream subscription
    //   _streamSubscription = notificationsStream.listen((snapshot) {
    //     // Handle the data from the stream
    //   });
    // } catch (e) {
    //   // Handle any errors (e.g., network issues, Firestore exceptions)
    //   print("Error fetching notifications: $e");
    // }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cancel the stream subscription
    _notificationsStreamController.close(); // Close the stream controller
    print("here");
    super.dispose(); // Call super.dispose() last
  }
}
