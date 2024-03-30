import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/signincontroller.dart';
import 'package:sametsalah/other/vali_input.dart';
import '../other/custombuttonauth.dart';
import '../other/customtextfieldauth.dart';
import '../other/logoimage.dart';

import 'package:sametsalah/controllers/home_controller.dart';

final MainController controller = Get.put(MainController());

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    LoginControllerImp controller_ = Get.put(LoginControllerImp());
    final double w = Get.width;
    final double h = Get.height;
    String theme = controller.isDark.isTrue ? "w" : "r";
    return SafeArea(
        child: Scaffold(
      body: Form(
        key: controller_.formstate,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: h * 0.1),
              Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                width: w,
                child: Column(
                  children: [
                    Text(
                      "Login for Admin",
                      style: TextStyle(
                          color: controller.isDark.isTrue
                              ? controller.primary_dark_color.value
                              : controller.primary_light_color.value,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    LogoImage(path: "images/${theme}icon.png"),
                    SizedBox(
                      height: 15,
                    ),
                    CustomTextFieldAuth(
                      isPassword: false,
                      isNumber: false,
                      valid: (value) {
                        return validatefunc_input(value!, 5, 100, "username");
                      },
                      label: "user name",
                      hinttext: "enter your user name",
                      icondata: Icons.email_outlined,
                      mycontroller: controller_.email,
                    ),
                    CustomTextFieldAuth(
                      isNumber: false,
                      isPassword: controller_.isshowpass,
                      ontapicon: () {
                        controller_.showpass();
                      },
                      valid: (value) {
                        return validatefunc_input(value!, 5, 30, "password");
                      },
                      label: "password",
                      hinttext: "Enter your Password",
                      icondata: Icons.lock_clock_outlined,
                      mycontroller: controller_.password,
                    ),
                    CustomButtonAuth(
                      width: w,
                      text: "login",
                      onpressed: () {
                        controller_.login();
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
