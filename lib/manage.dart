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
    ManageControllerImp controller= Get.put(ManageControllerImp());
    final double w=Get.width;
    return Scaffold(appBar:AppBar(title:Text("Manage Page"),),
      body: Column(children:
      [
        CustomTextFieldAuth(
          isPassword: false,
          isNumber:false ,
          valid: (value)
          {
            return validatefunc_input(value!, 5, 50, "");
          },
          label: "Title",
          hinttext: "Enter Notification title",
          icondata: Icons.notification_add,
          mycontroller: controller.title_notification,
        ),
        CustomTextFieldAuth(
          isPassword: false,
          isNumber:false ,
          valid: (value)
          {
            return validatefunc_input(value!, 5, 220, "");
          },
          label: "Body",
          hinttext: "Enter Notification Body",
          icondata: Icons.notification_important_outlined,
          mycontroller: controller.body_notification,
        ),
        CustomButtonAuth(
          widthh:w ,
          text:"Send Notification",
          onpressed: ()
          {
            controller.sendnotificationanddio();
          },
        ),      ],) ,);
  }
}
