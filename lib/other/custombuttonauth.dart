import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';

final MainController controller = Get.put(MainController());

class CustomButtonAuth extends StatelessWidget {
  final String text;
  final Function()? onpressed;
  final double width;
  const CustomButtonAuth(
      {Key? key, required this.text, this.onpressed, required this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.only(top: 5),
      child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
          color: controller.isDark.isTrue
              ? controller.primary_dark_color
              : controller.primary_light_color,
          child: Text(
            text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins'),
          ),
          onPressed: onpressed),
    );
  }
}
