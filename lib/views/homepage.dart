import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:http/http.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/main.dart';
import 'package:sametsalah/views/aboutuspage.dart';
import 'package:sametsalah/views/contactuspage.dart';
import 'package:sametsalah/views/loginpage.dart';
import 'package:sametsalah/views/notificationpage.dart';
import 'package:sametsalah/views/settingspage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';

final MainController controller = Get.put(MainController());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final phone_h = MediaQuery.of(context);
    print("fdassssssssssssssssssssssssssssssssssssssssssssss");

    print(phone_h.size.height);
    print(phone_h.size.width);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      controller.updateTime();
    });
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Prayer Times',
        theme: controller.isDark.isTrue ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          key: _scaffoldKey, // Assigning key to Scaffold
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "images/${controller.theme_value}_${controller.theme_color.value}.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState
                          ?.openDrawer(); // Using scaffold key to open drawer
                    },
                    icon: Icon(Icons.menu_sharp,
                        size: 30,
                        color: controller.isDark.isTrue
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, right: 10),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(NotificationPage());
                         
                        },
                        child: Icon(Icons.notifications_none,
                            size: 30,
                            color: controller.isDark.isTrue
                                ? Colors.white
                                : Colors.black),
                      ),
                      Visibility(
                        visible: controller.unreadcount != 0,
                        child: Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 13,
                                height: 13,
                                child: Center(
                                  child: AutoSizeText(
                                    '${controller.unreadcount}',
                                    textScaleFactor: 0.8,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 0.2 * phone_h.size.height),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width * 0.2605,
                          height: phone_h.size.height * 0.048,
                          child: Center(
                            child: AutoSizeText(
                              controller.dayName,
                              textScaleFactor: phone_h.size.width * 0.004271,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width * 0.65,
                          height: phone_h.size.height * 0.048,
                          child: Center(
                            child: AutoSizeText(
                              controller.hijriDate,
                              textScaleFactor: phone_h.size.width * 0.00391,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width * 0.65,
                          height: phone_h.size.height * 0.048,
                          child: Center(
                            child: AutoSizeText(
                              controller.gregorianDateDisplay,
                              textScaleFactor: phone_h.size.width * 0.00391,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width * 0.7793,
                          height: phone_h.size.height * 0.0954,
                          child: Center(
                            child: AutoSizeText(
                              controller.prayertime_12format(
                                  controller.currentTime.value),
                              textScaleFactor: phone_h.size.width * 0.0105,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width,
                          height: phone_h.size.height * 0.048,
                          child: Center(
                            child: AutoSizeText(
                              "سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ",
                              textScaleFactor: phone_h.size.width * 0.00417,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: phone_h.size.width * 0.9,
                          height: phone_h.size.height * 0.048,
                          child: Center(
                            child: AutoSizeText(
                              "Islamic Center of Brushy Creek",
                              textScaleFactor: phone_h.size.width * 0.003646,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.prayerTimes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return prayertimecard(
                              index: index,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          drawer: Drawer(
            surfaceTintColor: controller.isDark.isTrue
                ? controller.primary_dark_color.value
                : controller.primary_light_color.value,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/logo_white.png",
                        height: 100,
                        width: 100,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: controller.isDark.isTrue
                        ? controller.primary_dark_color.value
                        : controller.primary_light_color.value,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(LoginPage());
                  },
                  child: ListTile(
                    title: Text("Login"),
                    trailing: Icon(
                      Icons.manage_accounts_rounded,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(SettingsPage());
                  },
                  child: ListTile(
                    title: Text("Settings"),
                    trailing: Icon(
                      Icons.settings,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(Contact_Page());
                  },
                  child: ListTile(
                    title: Text("Contact us"),
                    trailing: Icon(
                      Icons.contact_page,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(About_us_page());
                  },
                  child: ListTile(
                    title: Text("About us"),
                    trailing: Image(
                      image: AssetImage(
                          "images/aboutus_${controller.theme_value}.png"),
                      width: 27,
                      height: 27,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class prayertimecard extends StatelessWidget {
  int index;
  prayertimecard({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final phone_h = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Card(
        color: controller.isDark.isTrue
            ? const Color.fromARGB(255, 57, 56, 56)
            : null, // Set color only when isDark is true
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/PrayerTime${index.toString()}.png', // Replace 'prayer_icon.png' with your icon asset path
                    width: 25, // Adjust width as needed
                    height: 25, // Adjust height as needed
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if (index != 1 && controller.dayName != "Friday") ...[
                    SizedBox(
                      width: phone_h.size.width * 0.25,
                      height: phone_h.size.height * 0.035,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            controller.getPrayerName(index),
                            textScaleFactor: phone_h.size.width * 0.00208,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'images/Azan.png', // Replace 'prayer_icon.png' with your icon asset path
                      width: 35, // Adjust width as needed
                      height: 35, // Adjust height as needed
                    ),
                    SizedBox(
                      width: phone_h.size.width * 0.23,
                      height: phone_h.size.height * 0.037,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            controller.prayertime_12format(
                                controller.prayerTimes[index]),
                            textScaleFactor: phone_h.size.width * 0.003125,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                      width: 35, // Adjust width as needed
                      height: 35, // Adjust height as needed
                    ),
                    SizedBox(
                      width: phone_h.size.width * 0.2,
                      height: phone_h.size.height * 0.037,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            controller.prayertime_12format(
                                controller.prayerTimes_iqama[index]),
                            textScaleFactor: phone_h.size.width * 0.003125,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ] else if (controller.dayName != "Friday") ...[
                    SizedBox(
                      width: phone_h.size.width * 0.47,
                      height: phone_h.size.height * 0.035,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            controller.getPrayerName(index),
                            textScaleFactor: phone_h.size.width * 0.0020833,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'images/Azan.png', // Replace 'prayer_icon.png' with your icon asset path
                      width: 0, // Adjust width as needed
                      height: 35, // Adjust height as needed
                      color: Colors.transparent,
                    ),
                    SizedBox(
                      width: phone_h.size.width * 0.2,
                      height: phone_h.size.height * 0.037,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            controller.prayertime_12format(
                                controller.prayerTimes_iqama[index]),
                            textScaleFactor: phone_h.size.width * 0.003125,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ] else if (controller.dayName == "Friday") ...[
                    SizedBox(
                      width: index != 1 && index != 2
                          ? phone_h.size.width * 0.25
                          : index == 1
                              ? phone_h.size.width * 0.47
                              : phone_h.size.width * 0.22,
                      height: phone_h.size.height * 0.035,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            index == 2
                                ? "Jumu'ah"
                                : controller.getPrayerName(index),
                            textScaleFactor: phone_h.size.width * 0.003125,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    if (index != 1 && index != 2) ...[
                      Image.asset(
                        'images/Azan.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 35, // Adjust width as needed
                        height: 35, // Adjust height as needed
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.23,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes[index]),
                              textScaleFactor: phone_h.size.width * 0.003125,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 35, // Adjust width as needed
                        height: 35, // Adjust height as needed
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.2,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes_iqama[index]),
                              textScaleFactor: phone_h.size.width * 0.003125,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ] else if (index == 1) ...[
                      Image.asset(
                        'images/Azan.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 0, // Adjust width as needed
                        height: 35, // Adjust height as needed
                        color: Colors.transparent,
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.2,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes_iqama[index]),
                              textScaleFactor: phone_h.size.width * 0.003125,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ] else if (index == 2) ...[
                      Image.asset(
                        'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 35, // Adjust width as needed
                        height: 35, // Adjust height as needed
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.12,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes_Jumuah[0]),
                              textScaleFactor: phone_h.size.width * 0.0018,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 35, // Adjust width as needed
                        height: 35, // Adjust height as needed
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.12,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes_Jumuah[1]),
                              textScaleFactor: phone_h.size.width * 0.0018,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                        width: 35, // Adjust width as needed
                        height: 35, // Adjust height as needed
                      ),
                      SizedBox(
                        width: phone_h.size.width * 0.13,
                        height: phone_h.size.height * 0.037,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              controller.prayertime_12format(
                                  controller.prayerTimes_Jumuah[2]),
                              textScaleFactor: phone_h.size.width * 0.0018,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ]
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String combinePrayerTimeWithMinutes(String prayerTime, int additionalMinutes) {
  // Parse the prayer time to a DateTime object
  DateTime parsedTime = DateTime.parse('2022-01-01 $prayerTime');

  // Add the additional minutes to the prayer time
  DateTime newTime = parsedTime.add(Duration(minutes: additionalMinutes));

  // Format the new time to HH:mm format
  String formattedTime =
      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
  // Return the formatted time
  return formattedTime;
}
