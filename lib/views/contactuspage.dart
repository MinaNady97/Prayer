import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final MainController controller = Get.put(MainController());

class Contact_Page extends StatelessWidget {
  const Contact_Page({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Contact us".tr,
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
                vertical: Get.height * 0.03, horizontal: 15),
            child: ListView(
              children: [
                Image.asset(
                  "images/iconword.png",
                  width: Get.width * 0.7,
                  height: Get.height * 0.4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "(512) 850-4786".tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(width: 10), // Adjust the spacing between icons
                    InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse("tel:+5128504786"));
                      },
                      child: Icon(
                        Icons.phone,
                        color: controller.isDark.isTrue
                            ? controller.primary_dark_color
                            : controller.primary_light_color,
                        size: 35,
                      ),
                    ),
                    // SizedBox(width: 10), // Adjust the spacing between icons
                    // InkWell(
                    //   onTap: () async {
                    //     final whatsappUrl = "https://wa.me/+5128504786";
                    //     print(await canLaunchUrl(Uri.parse(whatsappUrl)));
                    //     if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                    //       await launchUrl(Uri.parse(whatsappUrl));
                    //     } else {
                    //       print('Could not launch $whatsappUrl');
                    //     }
                    //   },
                    //   child: Image(
                    //     image: AssetImage("images/whatsapp.png"),
                    //     width: 45,
                    //     height: 45,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'info@icbrushycreek.org',
                    );
                    await launchUrl(emailLaunchUri);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("info@icbrushycreek.org".tr,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start),
                      Icon(
                        Icons.mail,
                        color: controller.isDark.isTrue
                            ? controller.primary_dark_color
                            : controller.primary_light_color,
                        size: 35,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    final Uri locationUri = Uri.parse(
                        "https://www.google.com/maps/place/1950+Brushy+Creek+Rd,+Cedar+Park,+TX+78613,+USA/@30.5079895,-97.7919772,17z/data=!3m1!4b1!4m6!3m5!1s0x865b2d3135974495:0x4a992bf37378ef9f!8m2!3d30.5079895!4d-97.7919772!16s%2Fg%2F11ff5dc2z6?entry=ttu");
                    await launchUrl(locationUri);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ICBC location".tr,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start),
                      Icon(
                        Icons.location_on,
                        color: controller.isDark.isTrue
                            ? controller.primary_dark_color
                            : controller.primary_light_color,
                        size: 35,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
