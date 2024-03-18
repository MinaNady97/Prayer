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
import 'package:sametsalah/PrayerTimesStorage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sametsalah/notification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dart:math';

late var service;
final MainController controller = Get.put(MainController());
late var isRunning;
List<String> prayerTimes = List.filled(5, '');
List<String> _prayertimes = [];
List<QueryDocumentSnapshot> constants = [];
bool flag = true;
bool data_month_flag = false;
bool first_day_flag = true;
late SharedPreferences instance;
List<String> prayerTimes_ = List.filled(5, '');
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  constants = controller.constants;
  instance = await SharedPreferences.getInstance();
  final now_ = DateTime.now();
  final String formattedDate =
      '${_addLeadingZero(now_.day)}-${_addLeadingZero(now_.month)}-${_addLeadingZero(now_.year)}';
  final List<dynamic>? storedPrayerTimes_ =
      await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);
  if (storedPrayerTimes_ == null) {
    instance.clear();
    await fetchPrayerTimingsForMonth();
  }
  // Call setupFirebaseMessaging to initialize Firebase Cloud Messaging
  setupFirebaseMessaging();

  runApp(MyApp());
}

String? getKeyFromValue(Map<String, String> map, String value) {
  for (var entry in map.entries) {
    if (entry.value.trim() == value.trim()) {
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
  var index = 0;

  if (now.hour > int.parse(controller.prayerTimes[4].split(":")[0])) {
    index = 1;
  }
  for (var x in controller.prayerTimes) {
    final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('${now.year}-${now.month}-${now.day + index} ${x}');
    final timeDiffInMinutes = (prayerTime.difference(now).inMinutes);

    // Check if prayer time is in the future (positive difference)
    if (timeDiffInMinutes > 0 && timeDiffInMinutes < closestDiffInMinutes) {
      closestKey = x;
      closestDiffInMinutes = timeDiffInMinutes;
    }
  }
  // Convert the closest time difference to hours and remaining minutes
  final hours = closestDiffInMinutes ~/ 60;
  final remainingMinutes = (closestDiffInMinutes % 60) + 1;

  return [closestKey, hours, remainingMinutes];
}

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  service.on('stopService').listen((event) async {
    await service.stopSelf();
    controller.enable_sound();
  });

  String aftertime = "";

  Timer.periodic(
    const Duration(seconds: 3),
    (timer) async {
      var now = DateTime.now();
      String currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      String? key;

      if (controller.prayerTimes.contains(currentTime)) {
        key = _getPrayerName(controller.prayerTimes.indexOf(currentTime));
      } else {
        key = null;
      }

      if (key != null && flag == true) {
        print('The key for the value is: $key');

        controller.checkLocation();

        try {
          var h = (int.parse(controller.constants[0]["times"][key]) ~/ 60) +
              now.hour;
          var m = (int.parse(controller.constants[0]["times"][key]) % 60) +
              now.minute;
          aftertime =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
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
          List closest_prayer_time = findClosestPrayerTime();
          String _content = "";
          try {
            var index = controller.prayerTimes.indexOf(closest_prayer_time[0]);
            _content =
                "${_getPrayerName(index)} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m";
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
    __fetchPrayerTimings();
  }

  Future<void> __fetchPrayerTimings() async {
    try {
      // Get the current date
      final now = DateTime.now();
      final String formattedDate =
          '${_addLeadingZero(now.day)}-${_addLeadingZero(now.month)}-${_addLeadingZero(now.year)}';

      // Retrieve prayer timings for the current date from local storage
      final List<dynamic>? storedPrayerTimes =
          await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

      if (storedPrayerTimes != null) {
        // Extract prayer times and additional information from stored data
        prayerTimes_ = storedPrayerTimes.sublist(0, 5).cast<String>();

        final String dayName = storedPrayerTimes[5];
        final String gregorianDate = storedPrayerTimes[6];
        final String gregorianDateDisplay = storedPrayerTimes[7];
        final String hijriDate = storedPrayerTimes[8];

        // Now you have the prayer times and additional information for the current date
        // You can use this data as needed

        setState(() {
          prayerTimes[0] = prayerTimes_[0].split(" ")[0];
          prayerTimes[1] = prayerTimes_[1].split(" ")[0];
          prayerTimes[2] = prayerTimes_[2].split(" ")[0];
          prayerTimes[3] = prayerTimes_[3].split(" ")[0];
          prayerTimes[4] = prayerTimes_[4].split(" ")[0];
        });
      } else {
        throw Exception('No locally saved data found for the current date');
      }
    } catch (e) {
      // Handle errors
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
}

// Function to handle notification click event
void handleNotificationClick() {
  // Navigate to NotificationPage
  runApp(MaterialApp(
    home: NotificationPage(),
  ));
}

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle notification click event
    handleNotificationClick();
  });
}

Future<void> fetchPrayerTimingsForMonth() async {
  var url =
      'https://api.aladhan.com/v1/calendar?method=2&latitude=30.508188279926383&longitude=-97.79224473202267&tune=0,0,0,0,0,0,0,0,0';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];

      for (var item in data) {
        print("fffffffffffffffffffffffffffffffffffffffffffffffff");
        print(item);
        final Map<String, dynamic> timings = item['timings'];
        final Map<String, dynamic> dateInfo = item['date'];

        final String dayName = dateInfo['gregorian']['weekday']['en'];
        final String gregorianDate = dateInfo['gregorian']['date'];
        final String gregorianDate_display =
            '${dateInfo['gregorian']['day']} ${dateInfo['gregorian']['month']['en']} ${dateInfo['gregorian']['year']}';
        final String hijriDate =
            '${dateInfo['hijri']['month']['en']} ${dateInfo['hijri']['day']} ${dateInfo['hijri']['year']}';

        final List<String> prayerTimes = [
          timings['Fajr'].split(" ")[0],
          timings['Dhuhr'].split(" ")[0],
          timings['Asr'].split(" ")[0],
          timings['Maghrib'].split(" ")[0],
          timings['Isha'].split(" ")[0],
        ];

        // Save prayer times and additional information for the current date locally
        await PrayerTimesStorage.savePrayerTimesForDate(
            gregorianDate,
            prayerTimes,
            dayName,
            gregorianDate,
            gregorianDate_display,
            hijriDate);
      }
      data_month_flag = true;
    } else {
      throw Exception('Failed to load prayer timings');
    }
  } catch (e) {
    print("ccccccccccccccccccccccccccccccccccccccccc");
  }
}

// Function to add leading zero if the value is less than 10
String _addLeadingZero(int value) {
  return value.toString().padLeft(2, '0');
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
