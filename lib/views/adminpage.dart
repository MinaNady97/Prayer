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
            // SizedBox(
            //   height: 15,
            // ),
            // Text(
            //   'Time between Azan And Eqama',
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            // ),
            // Form(
            //   key: controller.form_time_state,
            //   child: Column(
            //     children: [
            //       Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: Text(
            //               "Fajr",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18,
            //                 color: _controller.isDark.isTrue
            //                     ? _controller.primary_dark_color
            //                     : _controller.primary_light_color,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 3,
            //             child: CustomTextFieldAuth(
            //               isPassword: false,
            //               isNumber: true,
            //               valid: (value) {
            //                 return validatefunc_input(value!, 1, 2, "times");
            //               },
            //               label: "Fajr",
            //               hinttext: "Fajr time",
            //               icondata: Icons.timer,
            //               mycontroller: controller.Fajr,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: Text(
            //               "Dhuhr",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18,
            //                 color: _controller.isDark.isTrue
            //                     ? _controller.primary_dark_color
            //                     : _controller.primary_light_color,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 3,
            //             child: CustomTextFieldAuth(
            //               isPassword: false,
            //               isNumber: true,
            //               valid: (value) {
            //                 return validatefunc_input(value!, 1, 2, "times");
            //               },
            //               label: "Dhuhr",
            //               hinttext: "Dhuhr time",
            //               icondata: Icons.timer,
            //               mycontroller: controller.Dhuhr,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: Text(
            //               "Asr",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18,
            //                 color: _controller.isDark.isTrue
            //                     ? _controller.primary_dark_color
            //                     : _controller.primary_light_color,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 3,
            //             child: CustomTextFieldAuth(
            //               isPassword: false,
            //               isNumber: true,
            //               valid: (value) {
            //                 return validatefunc_input(value!, 1, 2, "times");
            //               },
            //               label: "Asr",
            //               hinttext: "Asr time",
            //               icondata: Icons.timer,
            //               mycontroller: controller.Asr,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: Text(
            //               "Maghrib",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18,
            //                 color: _controller.isDark.isTrue
            //                     ? _controller.primary_dark_color
            //                     : _controller.primary_light_color,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 3,
            //             child: CustomTextFieldAuth(
            //               isPassword: false,
            //               isNumber: true,
            //               valid: (value) {
            //                 return validatefunc_input(value!, 1, 2, "times");
            //               },
            //               label: "Maghrib",
            //               hinttext: "Maghrib time",
            //               icondata: Icons.timer,
            //               mycontroller: controller.Maghrib,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             flex: 1,
            //             child: Text(
            //               "Isha",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18,
            //                 color: _controller.isDark.isTrue
            //                     ? _controller.primary_dark_color
            //                     : _controller.primary_light_color,
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             flex: 3,
            //             child: CustomTextFieldAuth(
            //               isPassword: false,
            //               isNumber: true,
            //               valid: (value) {
            //                 return validatefunc_input(value!, 1, 2, "times");
            //               },
            //               label: "Isha",
            //               hinttext: "Isha time",
            //               icondata: Icons.timer,
            //               mycontroller: controller.Isha,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            // CustomButtonAuth(
            //   width: w,
            //   text: "save times",
            //   onpressed: () {
            //     controller.update_time();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
