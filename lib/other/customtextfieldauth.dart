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
              ? controller.primary_dark_color
              : controller.primary_light_color,
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
                        ? controller.primary_dark_color
                        : controller.primary_light_color),
                borderRadius: BorderRadius.circular(30)),
            iconColor: controller.isDark.isTrue
                ? controller.primary_dark_color
                : controller.primary_light_color,
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
                    ? controller.primary_dark_color
                    : controller.primary_light_color,
              ),
              onTap: ontapicon,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color
                        : controller.primary_light_color),
                borderRadius: BorderRadius.circular(30)),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color
                        : controller.primary_light_color),
                borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}
