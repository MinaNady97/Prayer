import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:http/http.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/main.dart';
import 'package:sametsalah/views/loginpage.dart';
import 'package:sametsalah/views/notificationpage.dart';

final MainController controller = Get.put(MainController());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      controller.updateTime();
    });
    return Obx(
      () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Prayer Times',
          theme:
              controller.isDark.isTrue ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            drawer: Drawer(
              surfaceTintColor: Colors.orangeAccent,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Row(
                      children: [
                        Image.asset(
                          "images/yh.png",
                          height: 100,
                          width: 100,
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 83, 179, 168),
                    ),
                  ),
                  ListTile(
                    title: Text('Theme'),
                    trailing: Obx(() => Switch(
                          value: controller.isDark.value,
                          onChanged: (bool value) {
                            controller.changeTheme(value);
                          },
                        )),
                  ),
                  ListTile(
                    title: Text('Auto Silent'),
                    trailing: Switch(
                      value: controller
                          .service_is_runing.value, // Placeholder value
                      onChanged: (bool value) async {
                        controller.isRunning = await service.isRunning();
                        if (controller.isRunning) {
                          controller.change_service_statu(false);
                          service.invoke("stopService");
                          await controller.enable_sound();
                          controller.flag = true;
                          print("hereeeeeeeeeeeeeeeeeeeeee");
                        } else {
                          service.startService();
                          controller.change_service_statu(true);
                        }
                      },
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Get.to(LoginPage());
                      },
                      child: ListTile(
                        title: Text("Login As Admin"),
                        trailing: Icon(
                          Icons.manage_accounts_rounded,
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        Get.to(NotificationPage());
                      },
                      child: ListTile(
                        title: Text("Notifications"),
                        trailing: Icon(
                          Icons.notifications_active_sharp,
                        ),
                      ))
                ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/${controller.theme_value}.png"),
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  SizedBox(
                    height: 90,
                  ),
                  Text(
                    controller.dayName,
                    style: TextStyle(fontSize: 23),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    controller.hijriDate,
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(controller.gregorianDateDisplay,
                      style: TextStyle(fontSize: 15)),
                  Text(
                    controller.currentTime.value,
                    style: TextStyle(fontSize: 60),
                  ),
                  Text(
                      "سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ"),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Islamic Center of Brushy Creek",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(child: PrayerTimesPage()),
                ],
              ),
            ),
            appBar: AppBar(
              // title: Text("Home"),
              backgroundColor: const Color.fromARGB(255, 83, 179, 168),
            ),
          )),
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  // String location = 'Texas'; // Change to your desired location
  // String method =
  //     '2'; // Change the method according to your preference, check API documentation for available methods
  // String apiUrl = ''; // Declare apiUrl variable here

  // 5 prayer times

  @override
  void initState() {
    print("main init");
    super.initState();
    print("main init 2");
    controller.fetchPrayerTimings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: controller.prayerTimes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: controller.isDark.isTrue
                  ? const Color.fromARGB(255, 57, 56, 56)
                  : null, // Set color only when isDark is true
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/PrayerTime${index.toString()}.png', // Replace 'prayer_icon.png' with your icon asset path
                      width: 24, // Adjust width as needed
                      height: 24, // Adjust height as needed
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.getPrayerName(index),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          //SizedBox(height: 4),
                        ],
                      ),
                    ),
                    Text(
                      controller.prayerTimes[index],
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
