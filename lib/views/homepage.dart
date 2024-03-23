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
        theme: controller.isDark.isTrue ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          drawer: Drawer(
            surfaceTintColor: controller.isDark.isTrue
                ? controller.primary_dark_color
                : controller.primary_light_color,
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
                        ? controller.primary_dark_color
                        : controller.primary_light_color,
                  ),
                ),
                ListTile(
                  title: Text('Dark Theme'),
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
                    value:
                        controller.service_is_runing.value, // Placeholder value
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
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.to(NotificationPage());
                  },
                  child: ListTile(
                    title: Text("Notifications"),
                    trailing: Icon(
                      Icons.notifications_active_sharp,
                    ),
                  ),
                )
              ],
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/${controller.theme_value}.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      controller.dayName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      controller.hijriDate,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      controller.gregorianDateDisplay,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      controller.currentTime.value,
                      style: TextStyle(fontSize: 60),
                    ),
                    Text(
                      "سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ",
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Islamic Center of Brushy Creek",
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 290,
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
            ],
          ),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: controller.isDark.isTrue
                  ? Colors.white
                  : Colors.white, // Change icon color based on theme
            ),
            backgroundColor: controller.isDark.isTrue
                ? controller.primary_dark_color
                : controller.primary_light_color,
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
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/PrayerTime${index.toString()}.png', // Replace 'prayer_icon.png' with your icon asset path
                    width: 24, // Adjust width as needed
                    height: 24, // Adjust height as needed
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      controller.getPrayerName(index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Image.asset(
                    'images/Azan.png', // Replace 'prayer_icon.png' with your icon asset path
                    width: 40, // Adjust width as needed
                    height: 40, // Adjust height as needed
                  ),
                  Expanded(
                    child: Text(
                      controller.prayerTimes[index],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Image.asset(
                    'images/IQAMAH.png', // Replace 'prayer_icon.png' with your icon asset path
                    width: 40, // Adjust width as needed
                    height: 40, // Adjust height as needed
                  ),
                  Expanded(
                    child: Text(
                      combinePrayerTimeWithMinutes(
                          controller.prayerTimes[index],
                          int.parse(controller.constants[0]["times"]
                              [controller.getPrayerName(index)])),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
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
