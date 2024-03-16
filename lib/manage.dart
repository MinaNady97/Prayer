import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/vali_input.dart';

import 'custombuttonauth.dart';
import 'customtextfieldauth.dart';
import 'manage_controller.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    ManageControllerImp controller = Get.put(ManageControllerImp());
    final double w = Get.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Page"),
      ),
      body: ListView(
        children: [
          Text(
            'Notification Seting',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          Form(
            key: controller.form_notification_state,
            child: Column(
              children: [
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: false,
                  valid: (value) {
                    return validatefunc_input(value!, 5, 50, "notifications");
                  },
                  label: "Title",
                  hinttext: "Enter Notification title",
                  icondata: Icons.notification_add,
                  mycontroller: controller.title_notification,
                ),
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: false,
                  valid: (value) {
                    return validatefunc_input(value!, 5, 220, "notifications");
                  },
                  label: "Body",
                  hinttext: "Enter Notification Body",
                  icondata: Icons.notification_important_outlined,
                  mycontroller: controller.body_notification,
                ),
              ],
            ),
          ),
          CustomButtonAuth(
            widthh: w,
            text: "Send Notification",
            onpressed: () {
              controller.sendnotificationanddio();
            },
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'paryer Times',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          Form(
            key: controller.form_time_state,
            child: Column(
              children: [
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: true,
                  valid: (value) {
                    return validatefunc_input(value!, 1, 2, "times");
                  },
                  label: "Fajr",
                  hinttext: "Fajr time",
                  icondata: Icons.timer,
                  mycontroller: controller.Fajr,
                ),
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: true,
                  valid: (value) {
                    return validatefunc_input(value!, 1, 2, "times");
                  },
                  label: "Dhuhr",
                  hinttext: "Dhuhr time",
                  icondata: Icons.timer,
                  mycontroller: controller.Dhuhr,
                ),
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: true,
                  valid: (value) {
                    return validatefunc_input(value!, 1, 2, "times");
                  },
                  label: "Asr",
                  hinttext: "Asr time",
                  icondata: Icons.timer,
                  mycontroller: controller.Asr,
                ),
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: true,
                  valid: (value) {
                    return validatefunc_input(value!, 1, 2, "times");
                  },
                  label: "Maghrib",
                  hinttext: "Maghrib time",
                  icondata: Icons.timer,
                  mycontroller: controller.Maghrib,
                ),
                CustomTextFieldAuth(
                  isPassword: false,
                  isNumber: true,
                  valid: (value) {
                    return validatefunc_input(value!, 1, 2, "times");
                  },
                  label: "Isha",
                  hinttext: "Isha time",
                  icondata: Icons.timer,
                  mycontroller: controller.Isha,
                ),
              ],
            ),
          ),
          CustomButtonAuth(
            widthh: w,
            text: "save times",
            onpressed: () {
              controller.update_time();
            },
          ),
        ],
      ),
    );
  }
}
