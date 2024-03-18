import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  var pickedFile;

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
      await uploadImageToStorage();
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
        'Fajr': Fajr.text,
        'Dhuhr': Dhuhr.text,
        'Asr': Asr.text,
        'Maghrib': Maghrib.text,
        'Isha': Isha.text,
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

  Future<void> pickImage() async {
    final _picker = ImagePicker();
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print("error in pickImage");
    } else {
      Get.snackbar(
        'Done', // Title of the snackbar
        'Image Selected', // Message of the snackbar
        snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
        backgroundColor: Colors.grey[800], // Background color of the snackbar
        colorText: Colors.white, // Text color of the snackbar
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<File> convertXFileToFile(XFile xFile) async {
    return File(xFile.path);
  }

  Future<void> uploadImageToStorage() async {
    var imagePath = pickedFile;

    if (imagePath != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask =
          storageRef.putFile(await convertXFileToFile(imagePath));
      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        savenotificationToFirestore(downloadUrl);
        pickedFile = null;
      }
    } else {
      savenotificationToFirestore("");
      print("error in uploadImageToStorage");
    }
  }

  Future<void> savenotificationToFirestore(String imageUrl) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('notifications');

    // Get the documents in the collection ordered by timestamp in descending order
    QuerySnapshot querySnapshot =
        await collectionRef.orderBy('timestamp', descending: true).get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    // If there are more than 10 documents, delete the last one
    if (documents.length >= 10) {
      // Delete the last document
      // Delete the last document
      final lastDocumentData = documents.last.data() as Map<String, dynamic>;
      if (lastDocumentData != null) {
        String imageUrlToDelete = lastDocumentData['image_url'];
        await collectionRef.doc(documents.last.id).delete();

        // Delete the image from Firebase Cloud Storage
        if (imageUrlToDelete.isNotEmpty) {
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = storage.refFromURL(imageUrlToDelete);
          await ref.delete();
        }
      }
    }

    // Add the new notification
    await collectionRef.add({
      'title': title_notification.text,
      'body': body_notification.text,
      'image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
