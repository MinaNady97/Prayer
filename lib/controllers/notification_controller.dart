import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:sametsalah/controllers/home_controller.dart';

abstract class notification_controller extends GetxController {}

final MainController controller = Get.put(MainController());

class notification_controllerImp extends notification_controller {
  StreamController<QuerySnapshot> _notificationsStreamController =
      StreamController<QuerySnapshot>.broadcast(); // Use a broadcast stream

  StreamSubscription<QuerySnapshot>?
      _streamSubscription; // Declare the stream subscription

  Stream<QuerySnapshot> get notificationsStream =>
      _notificationsStreamController.stream;

  @override
  void onInit() async {
    controller.setthereadednotification();
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
