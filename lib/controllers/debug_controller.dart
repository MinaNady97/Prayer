import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';

abstract class debugcontroller extends GetxController {}

final MainController controller = Get.put(MainController());

class debugcontrollerIMP extends debugcontroller {
  @override
  late String content;
  TextEditingController textController = TextEditingController();
  void onInit() async {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> debug_update() async {
    content = await controller.debug_method(true);
    textController.text = content;
    //return controller.debug_method(true);
  }
}
