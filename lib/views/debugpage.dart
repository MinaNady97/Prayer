import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/debug_controller.dart';
import 'package:sametsalah/other/vali_input.dart';
import '../other/custombuttonauth.dart';
import '../other/customtextfieldauth.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

//import '/controllers/manage_controller.dart';
import 'package:sametsalah/controllers/home_controller.dart';

final MainController controller = Get.put(MainController());

class Debugpage extends StatelessWidget {
  const Debugpage({super.key});

  @override
  Widget build(BuildContext context) {
    debugcontrollerIMP _controller = Get.put(debugcontrollerIMP());
    double w = Get.width * 0.2;

    // Create a TextEditingController
    final TextEditingController _textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Debug".tr,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: controller.isDark.isTrue
            ? controller.primary_dark_color.value
            : controller.primary_light_color.value,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
        child: ListView(
          children: [
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical, // change it as needed
                  child: AutoSizeTextField(
                    controller: _textController,
                    readOnly: true,
                    minFontSize: 12,
                    maxLines: 5,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            CustomButtonAuth(
              width: w * 0.8,
              text: "Update",
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
                await _controller.debug_update();

                // Update the TextField with the content
                _textController.text = _controller.content;

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
