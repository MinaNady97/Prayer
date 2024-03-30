import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';

final MainController controller = Get.put(MainController());

class About_us_page extends StatelessWidget {
  const About_us_page({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "About us".tr,
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          backgroundColor: controller.isDark.isTrue
              ? controller.primary_dark_color
              : controller.primary_light_color,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: Get.height * 0.03, horizontal: 20),
            child: ListView(
              children: [
                Image.asset(
                  "images/iconword.png",
                  width: Get.width * 0.7,
                  height: Get.width * 0.4,
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "The Islamic Center of Brushy Creek (ICBC), a 501 (C) non-profit organization, was established in July 2007 to meet the spiritual and social needs of the Muslim population in North West Austin, Texas. Situated on a 6.177-acre land at 1950 Brushy Creek Road, Cedar Park, Texas, the property was purchased with the generous donations from our community members. ICBC is easily accessible from major highways and several residential communities. Approximately 400 Muslim families of various background and ethnicities live within a 10-mile radius of ICBC, and our community continues to grow rapidly."
                      .tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "OBJECTIVE",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(220, 127, 41, 53),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "To please Allah (swt) by following the teachings of the Qur’an and the Sunnah of His Prophet, Muhammad (pbuh). "
                      .tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "MISSION",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(220, 127, 41, 53),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "To serve the Muslim community by providing various services to meet their spiritual and social needs and by promoting the values and teachings of Islam in accordance with the Qur’an and Sunnah of His Prophet, Muhammad (pbuh)."
                      .tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "VISION",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(220, 127, 41, 53),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "To become a comprehensive center of learning and spirituality for all age groups and demographics within the Muslim community."
                      .tr,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }
}
