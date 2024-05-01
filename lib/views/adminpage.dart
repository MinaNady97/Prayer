import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/other/vali_input.dart';
import '../other/custombuttonauth.dart';
import '../other/customtextfieldauth.dart';
import '/controllers/manage_controller.dart';
import 'package:sametsalah/controllers/home_controller.dart';

final MainController _controller = Get.put(MainController());

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    ManageControllerImp controller = Get.put(ManageControllerImp());
    double w = Get.width * 0.2;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
        child: ListView(
          children: [
            AutoSizeText(
              'Send Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  CustomLargeTextFieldAuth(
                    isPassword: false,
                    isNumber: false,
                    valid: (value) {
                      return validatefunc_input(
                          value!, 5, 220, "notifications");
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
              width: w * 0.4,
              text: "select image ",
              onpressed: () {
                controller.pickImage();
              },
            ),
            CustomButtonAuth(
              width: w * 0.8,
              text: "Send Notification",
              onpressed: () async {
                // Show the progress indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Call your notification function
                await controller.sendnotificationanddio();

                // Hide the progress indicator
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
