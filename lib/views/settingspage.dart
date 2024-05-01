import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:sametsalah/main.dart';

final MainController controller = Get.put(MainController());

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text(
            "Settings Page",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          backgroundColor: controller.isDark.isTrue
              ? controller.primary_dark_color.value
              : controller.primary_light_color.value,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: Get.height * 0.03, horizontal: 20),
            child: Column(
              children: [
                ListTile(
                    title: Text(
                      'Auto silent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Obx(
                      () => Switch(
                        value: controller
                            .service_is_runing.value, // Placeholder value
                        onChanged: (bool value) async {
                          controller.isRunning = await service.isRunning();
                          if (controller.isRunning) {
                            controller.change_service_statu(false);
                            service.invoke("turnoffNotification");
                            service.invoke("stopService");
                            controller.flag = true;
                            controller.turnNotification(false);
                            print("hereeeeeeeeeeeeeeeeeeeeee");
                          } else {
                            await controller.initializeService();
                            await controller.service_configure();
                            // if (controller.flag == false) {
                            //   service.invoke("set_flags");
                            // }
                            await service.startService();

                            controller.change_service_statu(true);
                            controller.turnNotification(true);
                            service.invoke("turnonNotification");
                          }
                        },
                      ),
                    )),
                ListTile(
                  title: Text(
                    'Prayer time indicator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Obx(() => Switch(
                        value: controller.isNotification.value,
                        onChanged: (bool value) async {
                          print("hereeeeeeeeeeeeeeeeeeeeeeee");

                          controller.isRunning = await service.isRunning();
                          if (controller.isRunning) {
                            controller.turnNotification(value);
                          }
                        },
                      )),
                ),
                ListTile(
                  title: Text(
                    'Dark theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Obx(() => Switch(
                        value: controller.isDark.value,
                        onChanged: (bool value) {
                          controller.changeTheme(value);
                        },
                      )),
                ),
                ListTile(
                  title: Text(
                    'Theme color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Obx(() => CupertinoSlidingSegmentedControl<bool>(
                        thumbColor: skyColors[controller.selectedSky]!,
                        groupValue: controller.isRed.value,
                        onValueChanged: (bool? value) {
                          if (value != null) {
                            print(value);
                            setState(() {
                              controller.selectedSky =
                                  value ? Sky.red : Sky.blue;
                              controller.isRed.value = value;
                              controller.theme_color.value =
                                  value ? "red" : "blue";
                              controller.primary_dark_color.value = value
                                  ? Color.fromARGB(255, 127, 41, 53)
                                  : Color.fromARGB(255, 1, 50, 90);
                              controller.primary_light_color.value = value
                                  ? Color.fromARGB(255, 127, 41, 53)
                                  : Color.fromARGB(255, 1, 50, 90);
                            });
                            instance!.setBool("isRed", value);
                            // controller.changeThemeColor(value);
                          }
                        },
                        children: const <bool, Widget>{
                          true: Text(
                            'Red',
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                          false: Text(
                            'Blue',
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                        },
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
