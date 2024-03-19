import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/adminpage.dart';

abstract class LoginController extends GetxController {}

class LoginControllerImp extends LoginController {
  late TextEditingController email;
  late TextEditingController password;
  bool isshowpass = true;
  List<QueryDocumentSnapshot> constants = [];

  showpass() {
    isshowpass = isshowpass == true ? false : true;
    update();
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  loginfirebase() async {}
  @override
  void onInit() async {
    email = TextEditingController();
    password = TextEditingController();
    email.text = "";
    password.text = "";
    super.onInit();
  }

  login() async {
    try {
      await get_user_from_DB();

      var user_name_DB = constants[0]["user_name"];
      var password_DB = constants[0]["password"];

      if (formstate.currentState!.validate()) {
        if (email.text.trim() == user_name_DB &&
            password.text.trim() == password_DB) {
          Get.off(ManagePage(), arguments: constants);
        } else {
          Get.snackbar(
            'Alert', // Title of the snackbar
            'user name or password not is wrong', // Message of the snackbar
            snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
            backgroundColor:
                Colors.grey[800], // Background color of the snackbar
            colorText: Colors.white, // Text color of the snackbar
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      ;
    }
  }

  Future<void> get_user_from_DB() async {
    QuerySnapshot user_snapshot = await FirebaseFirestore.instance
        .collection(
            "constants") // get the colletion buses from database where it conaton station 1
        .get();
    constants.clear();
    constants.addAll(user_snapshot.docs);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
