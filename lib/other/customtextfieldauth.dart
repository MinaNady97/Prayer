import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';

final MainController controller = Get.put(MainController());

class CustomTextFieldAuth extends StatelessWidget {
  final String hinttext;
  final String label;
  final bool isNumber;
  final bool? isPassword;
  final void Function()? ontapicon;
  final IconData icondata;
  final String? Function(String?) valid;
  final TextEditingController mycontroller;
  CustomTextFieldAuth(
      {Key? key,
      required this.hinttext,
      this.ontapicon,
      required this.label,
      required this.icondata,
      required this.mycontroller,
      required this.valid,
      required this.isNumber,
      this.isPassword})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Container(
        height: 50,
        child: TextFormField(
          cursorColor: controller.isDark.isTrue
              ? controller.primary_dark_color.value
              : controller.primary_light_color.value,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          controller: mycontroller,
          obscureText: isPassword == Null || isPassword == false ? false : true,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          validator: valid,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
            iconColor: controller.isDark.isTrue
                ? controller.primary_dark_color.value
                : controller.primary_light_color.value,
            isDense: true,
            fillColor: Colors.grey,
            filled: true,
            hintText: hinttext,
            hintStyle: TextStyle(
              color: Color.fromRGBO(75, 72, 72, 1),
              fontSize: 14,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            suffixIcon: InkWell(
              child: Icon(
                icondata,
                color: controller.isDark.isTrue
                    ? controller.primary_dark_color.value
                    : controller.primary_light_color.value,
              ),
              onTap: ontapicon,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}

class CustomLargeTextFieldAuth extends StatelessWidget {
  final String hinttext;
  final String label;
  final bool isNumber;
  final bool? isPassword;
  final void Function()? ontapicon;
  final IconData icondata;
  final String? Function(String?) valid;
  final TextEditingController mycontroller;
  CustomLargeTextFieldAuth(
      {Key? key,
      required this.hinttext,
      this.ontapicon,
      required this.label,
      required this.icondata,
      required this.mycontroller,
      required this.valid,
      required this.isNumber,
      this.isPassword})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Container(
        height: 200, // Adjust this height as needed
        child: TextFormField(
          cursorColor: controller.isDark.isTrue
              ? controller.primary_dark_color.value
              : controller.primary_light_color.value,
          textDirection: TextDirection.ltr,
          textAlignVertical: TextAlignVertical.top, // Align text to the top
          textAlign: TextAlign.left, // Align text to the left
          controller: mycontroller,
          obscureText: isPassword == null || isPassword == false ? false : true,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          maxLines: null, // Enables multiline input
          validator: valid,
          style: TextStyle(fontSize: 20), // Set font size to 20
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
            iconColor: controller.isDark.isTrue
                ? controller.primary_dark_color.value
                : controller.primary_light_color.value,
            isDense: true,
            fillColor: Colors.grey,
            filled: true,
            hintText: hinttext,
            hintStyle: TextStyle(
              color: Color.fromRGBO(75, 72, 72, 1),
              fontSize: 20, // Set hint text font size to 20
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 20), // Adjust vertical padding here
            suffixIcon: InkWell(
              child: Icon(
                icondata,
                color: controller.isDark.isTrue
                    ? controller.primary_dark_color.value
                    : controller.primary_light_color.value,
              ),
              onTap: ontapicon,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value),
                borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}
