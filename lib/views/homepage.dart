import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:sametsalah/main.dart';
import 'package:sametsalah/views/loginpage.dart';
import 'package:sametsalah/views/notificationpage.dart';

final MainController controller = Get.put(MainController());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                        Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 23),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
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
                        Get.to(LoginPage(), arguments: constants);
                      },
                      child: ListTile(
                        title: Text("Login As Admin"),
                        trailing: Icon(
                          Icons.manage_accounts_rounded,
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        Get.to(NotificationPage(), arguments: constants);
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
            body: Column(
              children: [
                Text(
                  "Prayer Times",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                ),
                Image.asset(
                  "images/yh.png",
                  height: 160,
                ),
                Expanded(child: PrayerTimesPage()),
              ],
            ),
            appBar: AppBar(
              title: Text("Home"),
              backgroundColor: Colors.orangeAccent,
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
  String location = 'Texas'; // Change to your desired location
  String method =
      '2'; // Change the method according to your preference, check API documentation for available methods
  String apiUrl = ''; // Declare apiUrl variable here

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
      body: ListView.builder(
        itemCount: controller.prayerTimes.length,
        itemBuilder: (context, index) {
          return Center(
            child: Card(
              child: ListTile(
                title: Text(controller.getPrayerName(index)),
                subtitle: Text(controller.prayerTimes[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
