import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/signincontroller.dart';
import 'package:sametsalah/vali_input.dart';
import 'custombuttonauth.dart';
import 'customtextfieldauth.dart';
import 'logoimage.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    LoginControllerImp controller= Get.put(LoginControllerImp());
    final double w=Get.width;
    final double h=Get.height;
    return SafeArea(
      child: Scaffold(
        body:Form(
           key: controller.formstate,
          child: SingleChildScrollView(
                    child: Column(
                      children:
                      [
                        SizedBox(height:h*0.1),
                        Container(
                          padding: EdgeInsets.only(top: 20,left: 20,right: 20),
                          width: w,
                          child: Column(
                            children: [
                              Text("Login for Admin",style: TextStyle(color:Colors.orangeAccent,fontSize: 45,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),textAlign: TextAlign.center,),
                              SizedBox(height: 40,),
                              LogoImage(path:"images/yh.png"),
                              SizedBox(height: 15,),
                              CustomTextFieldAuth(
                                isPassword: false,
                                isNumber:false ,
                                valid: (value)
                                {
                                  return validatefunc_input(value!, 5, 100, "username");
                                },
                                label: "user name",
                                hinttext: "enter your user name",
                                icondata: Icons.email_outlined,
                                mycontroller: controller.email,
                              ),
                              CustomTextFieldAuth(
                                isNumber:false ,
                                isPassword: controller.isshowpass,
                                ontapicon: ()
                                {
                                  controller.showpass();
                                },
                                valid: (value)
                                {
                                  return validatefunc_input(value!, 5, 30, "password");
                                },
                                label: "password",
                                hinttext: "Enter your Password",
                                icondata: Icons.lock_clock_outlined,
                                mycontroller: controller.password,
                              ),

                              CustomButtonAuth(
                                widthh:w ,
                                text:"login",
                                onpressed: ()
                                {
                                  controller.login();
                                },
                              ),
                              const SizedBox(height: 20,),
                            ],
                          ),
                        )
                      ],),
                  ),
        ),

    ));
  }
}
