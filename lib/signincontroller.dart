import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'manage.dart';
abstract class LoginController extends GetxController
{
}
class LoginControllerImp extends LoginController
{
  late TextEditingController email;
  late TextEditingController password;
  bool isshowpass=true;
  showpass()
  {
    isshowpass=isshowpass==true?false:true;
    update();
  }
  GlobalKey<FormState> formstate=GlobalKey<FormState>();
  loginfirebase()async
  {

  }
  @override
  void onInit() async{
    email=TextEditingController();
    password=TextEditingController();
    email.text="";
    password.text="";
    super.onInit();
  }
  login()async
  {
    if (formstate.currentState!.validate()) {
       if(email.text=="shehap"&&password.text=="123456")
       {
        Get.off(ManagePage());
       }
      }}
@override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}