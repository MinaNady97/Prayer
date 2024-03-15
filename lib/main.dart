import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sametsalah/controller.dart';

import 'login.dart';

late var service;
final MainController controller = Get.put(MainController());
late var isRunning;
List<String> prayerTimes = List.filled(5, '');
List<String> _prayertimes = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(MyApp());
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

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  service.on('stopService').listen((event) async {
    await service.stopSelf();
    controller.enable_sound();
  });
  bool flag = true;
  Timer.periodic(
    const Duration(seconds: 1),
    (timer) async {
      var now = DateTime.now();
      String currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      String aftertime =
          '${now.hour.toString().padLeft(2, '0')}:${(now.minute - 15).toString().padLeft(2, '0')}';
      //print(controller.prayertime[0]);
      //print(currentTime);
      String formattedDate_now =
          '${controller.addLeadingZero(now.day)}-${controller.addLeadingZero(now.month)}-${now.year}';
      if (controller.formattedDate != formattedDate_now) {
        controller.fetchPrayerTimings();
      }
      print(controller.prayertime[0].contains(currentTime));
      if (controller.prayertime[0].contains(currentTime) && flag) {
        controller.checkLocation();
        flag = false;
      } else if (controller.prayertime[0].contains(aftertime)) {
        controller.enable_sound();
        flag = true;
      }
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "Auto Silent",
            content: "Updated at ${DateTime.now()}",
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
                          print("hereeeeeeeeeeeeeeeeeeeeee");
                        } else {
                          service.startService();
                          controller.change_service_statu(true);
                        }
                      },
                    ),
                  ),
                  InkWell(
                      onTap: ()
                      {
                       Get.to(LoginPage());
                      },
                      child: ListTile(title:Text("Login As Admin"),trailing: Icon(Icons.manage_accounts_rounded,),))
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
    var url = 'https://api.aladhan.com/v1/timings/' +
        formattedDate +
        '?latitude=' +
        position.latitude.toString() +
        '&longitude=' +
        position.longitude.toString();
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
