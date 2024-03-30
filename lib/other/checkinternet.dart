import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_upgrade_version/models/package_info.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

checkInternet() async {
  try {
    var result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return "internet";
    }
  } on SocketException catch (_) {
    return "nointernet";
  }
}

checkversion() async {
  try {
    var result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      QuerySnapshot querysnapshot2 =
          await FirebaseFirestore.instance.collection("constants").get();
      PackageInfo _packageInfo = PackageInfo();
      _packageInfo = await PackageManager.getPackageInfo();
      int ver = int.parse(_packageInfo.buildNumber);
      print("verrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      print(ver);
      if (ver < querysnapshot2.docs[0]['ver'])
        return "update_av";
      else
        return "noupdate_av";
    }
  } on SocketException catch (_) {
    return "nointernet";
  }
}

void showCustomSnackbar(String title, String message) {
  Get.rawSnackbar(
    backgroundColor: Colors.black,
    title: title,
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(seconds: 2), // Set the duration to 3 seconds
  );
}

void showredSnackbar(String title, String message) {
  Get.rawSnackbar(
    backgroundColor: Colors.red,
    title: title,
    messageText: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(seconds: 2), // Set the duration to 3 seconds
  );
}
