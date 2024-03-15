import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
abstract class ManageController extends GetxController
{
}
class ManageControllerImp extends ManageController
{
  late TextEditingController title_notification;
  late TextEditingController body_notification;

  GlobalKey<FormState> formstate=GlobalKey<FormState>();
  loginfirebase()async
  {

  }
  @override
  void onInit() async{
    title_notification=TextEditingController();
    body_notification=TextEditingController();
    title_notification.text="";
    body_notification.text="";
    super.onInit();
  }
  sendnotificationanddio()async
  {
    if (formstate.currentState!.validate()) {
      sendnotification();
      Get.snackbar(
          'Done', // Title of the snackbar
          'Notification Sent Successfully', // Message of the snackbar
          snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
          backgroundColor: Colors.grey[800], // Background color of the snackbar
          colorText: Colors.white, // Text color of the snackbar
          duration: Duration(seconds: 3),);
    }
  }
  @override
  void dispose() {
    title_notification.dispose();
    body_notification.dispose();
    super.dispose();
  }
  Future<void> sendnotification() async {
    final url = Uri.parse("");
    final bodyData = {
      'topic': "users",
      'body': body_notification.text,
      'title': title_notification.text,
    };
    final response = await http.post(url, body: bodyData);
    if (response.statusCode == 200) {
      print('Request successful');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}