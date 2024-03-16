import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sametsalah/controller.dart';
import 'package:sametsalah/fbnotify.dart';
import 'package:sametsalah/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';
import 'dart:math';

late var service;
final MainController controller = Get.put(MainController());
late var isRunning;
List<String> prayerTimes = List.filled(5, '');
List<String> _prayertimes = [];
List<QueryDocumentSnapshot> constants = [];
bool flag = true;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  constants = controller.constants;
  runApp(MyApp());
}

String? getKeyFromValue(Map<String, String> map, String value) {
  for (var entry in map.entries) {
    if (entry.value == value) {
      return entry.key;
    }
  }
  return null;
}

Future<void> initializeService() async {
  service = FlutterBackgroundService();
  isRunning = await service.isRunning();
  controller.service_is_runing.value = isRunning;
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onstart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onstart,

      // you have to enable background fetch capability on xcode project
      //onBackground: onIosBackground,
    ),
  );
}

List findClosestPrayerTime() {
  final now = DateTime.now();
  String closestKey = "loading";
  int closestDiffInMinutes =
      999999999999999999; // Initialize with maximum positive value

  controller.prayertime.forEach((key, value) {
    final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('${now.year}-${now.month}-${now.day} $value');
    final timeDiffInMinutes = -(now.difference(prayerTime).inMinutes);
    //print(timeDiffInMinutes);
    // Check if prayer time is in the future (positive difference)
    if (timeDiffInMinutes > 0 && timeDiffInMinutes < closestDiffInMinutes) {
      closestKey = key;
      closestDiffInMinutes = timeDiffInMinutes;
    }
  });

  // Convert the closest time difference to hours and remaining minutes
  final hours = closestDiffInMinutes ~/ 60;
  final remainingMinutes = closestDiffInMinutes % 60;

  return [closestKey, hours, remainingMinutes];
}

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  service.on('stopService').listen((event) async {
    await service.stopSelf();
    controller.enable_sound();
  });

  String aftertime = "";
  List closest_prayer_time = findClosestPrayerTime();
  Timer.periodic(
    const Duration(seconds: 60),
    (timer) async {
      var now = DateTime.now();
      String currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      //print(controller.prayertime[0]);
      //print(currentTime);
      String formattedDate_now =
          '${controller.addLeadingZero(now.day)}-${controller.addLeadingZero(now.month)}-${now.year}';
      if (controller.formattedDate != formattedDate_now) {
        controller.fetchPrayerTimings();
      }
      //print(controller.prayertime[0].contains(currentTime));
      String? key = getKeyFromValue(controller.prayertime, currentTime);
      //String key = "Dhuhr";
      // print(controller.prayertime[key]);
      // try {
      //   print(controller.constants[0]["times"][key]);
      // } catch (e) {
      //   print("eroor");
      // }
      //print(flag);
      if (key == null) {
        print('The key for the value is: null');
      } else if (key != null && flag == true) {
        print('The key for the value is: $key');

        controller.checkLocation();

        try {
          //print("time after $t ");
          aftertime =
              '${now.hour.toString().padLeft(2, '0')}:${(now.minute + int.parse(controller.constants[0]["times"][key])).toString().padLeft(2, '0')}';
          flag = false;
        } catch (e) {
          //print("eroor2");
          flag = true;
        }
      } else if (currentTime.trim() == aftertime.trim() && flag == false) {
        //print("here 2");
        controller.enable_sound();
        flag = true;
      }
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          closest_prayer_time = findClosestPrayerTime();
          String _content = "";
          try {
            _content =
                "${closest_prayer_time[0]} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m";
          } catch (e) {
            print("here");
          }
          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "Prayer Auto Silent",
            content: _content,
          );
        }
      }
    },
  );
}

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
                        isRunning = await service.isRunning();
                        if (isRunning) {
                          controller.change_service_statu(false);
                          service.invoke("stopService");
                          await controller.enable_sound();
                          flag = true;
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
    super.initState();

    fetchPrayerTimings();
  }

  // Function to add leading zero if the value is less than 10
  String _addLeadingZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> fetchPrayerTimings() async {
    var position = await controller.get_location();
    // Get the current date      https://api.aladhan.com/v1/timings/13-03-2024?latitude=30.0512613&longitude=31.3980016
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${_addLeadingZero(now.day)}-${_addLeadingZero(now.month)}-${now.year}';
    // var url = 'https://api.aladhan.com/v1/timings/' +
    //     formattedDate +
    //     '?latitude=' +
    //     position!.latitude.toString() +
    //     '&longitude=' +
    //     position!.longitude.toString();
    var url = 'https://api.aladhan.com/v1/timings/' +
        formattedDate +
        '?latitude=30.508188279926383&longitude=-97.79224473202267&tune=0,0,0,0,0,0,0,0,0';
    print(url);
    final response = await http.get(Uri.parse(url));
    print(response);
    if (response.statusCode == 200) {
      print("222222222222222222222222222222222");
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, dynamic> data = responseData['data'];
      print(data[0]);
      setState(() {
        prayerTimes[0] = data['timings']['Fajr'];
        prayerTimes[1] = data['timings']['Dhuhr'];
        prayerTimes[2] = data['timings']['Asr'];
        prayerTimes[3] = data['timings']['Maghrib'];
        prayerTimes[4] = data['timings']['Isha'];
      });

      // Find the entry corresponding to the current date
    } else {
      throw Exception('Failed to load prayer timings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: prayerTimes.length,
        itemBuilder: (context, index) {
          return Center(
            child: Card(
              child: ListTile(
                title: Text(_getPrayerName(index)),
                subtitle: Text(prayerTimes[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPrayerName(int index) {
    switch (index) {
      case 0:
        return 'Fajr';
      case 1:
        return 'Dhuhr';
      case 2:
        return 'Asr';
      case 3:
        return 'Maghrib';
      case 4:
        return 'Isha';
      default:
        return '';
    }
  }
}
