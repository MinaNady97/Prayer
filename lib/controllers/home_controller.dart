import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sametsalah/controllers/PrayerTimesStorage.dart';
import 'package:sametsalah/main.dart';
import 'package:sametsalah/views/notificationpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:http/http.dart' as http;
import 'package:sametsalah/other/firebase_options.dart';
import 'package:sametsalah/other/fbnotify.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final MainController control = Get.put(MainController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) async {
    await service.stopSelf();
    control.enable_sound();
  });

  String aftertime = "";

  Timer.periodic(
    const Duration(seconds: 5),
    (timer) async {
      var now = DateTime.now();
      String currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      String? key;

      if (control.prayerTimes.contains(currentTime)) {
        key = control.getPrayerName(control.prayerTimes.indexOf(currentTime));
      } else {
        key = null;
      }

      if (key != null && control.flag == true) {
        print('The key for the value is: $key');

        var checked = await control.checkLocation();
        if (checked) {
          try {
            await control.get_times_from_DB();
          } catch (e) {
            Get.snackbar(
              'No Internet', // Title of the snackbar
              'cant get the time for iqama, using defult value', // Message of the snackbar
              snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
              backgroundColor:
                  Colors.grey[800], // Background color of the snackbar
              colorText: Colors.white, // Text color of the snackbar
              duration: Duration(seconds: 3),
            );
          }
          var m = ((int.parse(control.constants[0]["times"][key]) % 60) +
                  now.minute) %
              60;

          var v = ((int.parse(control.constants[0]["times"][key]) % 60) +
                  now.minute) ~/
              60;

          var h = (int.parse(control.constants[0]["times"][key]) ~/ 60) +
              now.hour +
              v;

          if (h >= 24) {
            h = h % 24;
          }

          aftertime =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

          control.flag = false;
        }
      } else if (currentTime.trim() == aftertime.trim() &&
          control.flag == false) {
        //print("here 2");
        control.enable_sound();
        control.flag = true;
        aftertime = "";
      }

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          List closest_prayer_time = control.findClosestPrayerTime();
          String _content = "";
          try {
            var index = control.prayerTimes.indexOf(closest_prayer_time[0]);
            print(
                "gggggggggggggggggggggggggggggggggggggggggg${control.getPrayerName(index)}");
            _content =
                "${control.getPrayerName(index)} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m";
          } catch (e) {
            print("here");
          }
          flutterLocalNotificationsPlugin.show(
            888,
            'ICBC',
            _content,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'ICBC',
                'ICBC SERVICE',
                icon: 'yh',
                ongoing: true,
              ),
            ),
          );
          // if you don't using custom notification, uncomment this
          // service.setForegroundNotificationInfo(
          //   title: "ICBC",
          //   content: _content,
          // );
        }
      }
      // service.invoke(
      //   'update',
      //   {
      //     "current_date": DateTime.now().toIso8601String(),
      //   },
      // );
    },
  );
}

class MainController extends GetxController {
  RxBool isDark = true.obs;
  RxBool service_is_runing = false.obs;
  List<QueryDocumentSnapshot> constants = [];
  List<QueryDocumentSnapshot> coordinates = [];
  List<String> prayerTimes = List.filled(5, '00:00');
  String formattedDate = "";
  String targetLatitude = "";
  String targetLongitude = "";
  String dayName = "";
  String gregorianDate = "";
  String gregorianDateDisplay = "";
  String hijriDate = "";
  late var isRunning;
  List<String> _prayertimes = [];
  bool flag = true;
  bool data_month_flag = false;
  bool first_day_flag = true;
  late SharedPreferences instance;
  List<String> prayerTimes_ = List.filled(5, '');
  String theme_value = "dark";
  bool flag_test = false;
  var currentTime = "".obs;

  void changeTheme(bool value) {
    isDark.value = value;
    if (value) {
      theme_value = "dark";
    } else {
      theme_value = "light";
    }
    //update();
  }

  @override
  Future<void> onInit() async {
    print("first");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.instance.subscribeToTopic("users");

    await requestPermissionNotification();
    await requestLocationPermission();
    await requestnotifyPermission();
    fcmcofing();
    await get_times_from_DB();
    await get_coordinates_from_DB();
    await fetchPrayerTimings();

    super.onInit();
  }

  Future<Position?> get_location() async {
    try {
      Position _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      return _position;
    } catch (e) {
      return null;
    }
  }

  void change_service_statu(bool value) {
    service_is_runing.value = value;
    update();
  }

  String addLeadingZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> requestnotifyPermission() async {
    bool? isGranted = await PermissionHandler.permissionsGranted;
    if (!isGranted!) {
      // Opens the Do Not Disturb Access settings to grant the access
      await PermissionHandler.openDoNotDisturbSetting();
    } else {
      print('DoNotDisturb permission granted');
    }
  }

  Future<void> requestLocationPermission() async {
    // Check if location permission is granted
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      // Request location permission if not granted
      PermissionStatus permissionStatus = await Permission.location.request();

      if (permissionStatus.isGranted) {
        // Permission granted, proceed with your logic
        print('Location permission granted');
      } else {
        // Permission denied, handle accordingly
        print('Location permission denied');
      }
    } else if (status.isGranted) {
      // Permission already granted, proceed with your logic
      print('Location permission already granted');
    }
  }

  Future<bool> checkLocation() async {
    try {
      for (var location in coordinates) {
        targetLatitude = location["lat"];
        targetLongitude = location["long"];
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        double distanceInMeters = await Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          double.parse(targetLatitude),
          double.parse(targetLongitude),
        );
        if (distanceInMeters <= 100) {
          try {
            await SoundMode.setSoundMode(RingerModeStatus.silent);
            print("soind muted");
            return true;
          } on PlatformException {
            print('Please enable permissions required');
            Get.snackbar(
              'permissions', // Title of the snackbar
              'Please enable Dontditrub required', // Message of the snackbar
              snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
              backgroundColor:
                  Colors.grey[800], // Background color of the snackbar
              colorText: Colors.white, // Text color of the snackbar
              duration: Duration(seconds: 3),
            );
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      print("Error getting location: $e");
      return false;
    }
  }

  Future<void> enable_sound() async {
    try {
      await SoundMode.setSoundMode(RingerModeStatus.normal);
    } on PlatformException {
      print('Please enable permissions required');
    }
    print("soind enabled");
  }

  Future<void> get_times_from_DB() async {
    QuerySnapshot times_snapshot = await FirebaseFirestore.instance
        .collection(
            "constants") // get the colletion buses from database where it conaton station 1
        .get();
    constants.clear();
    constants.addAll(times_snapshot.docs);
  }

  Future<void> get_coordinates_from_DB() async {
    QuerySnapshot coordinates_snapshot = await FirebaseFirestore.instance
        .collection(
            "coordinates") // get the colletion buses from database where it conaton station 1
        .get();
    coordinates.clear();
    coordinates.addAll(coordinates_snapshot.docs); // add docs to list
  }

  Future<void> fetchPrayerTimings() async {
    try {
      // Get the current date
      final now = DateTime.now();
      final String formattedDate =
          '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${addLeadingZero(now.year)}';

      // Retrieve prayer timings for the current date from local storage
      final List<dynamic>? storedPrayerTimes =
          await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

      if (storedPrayerTimes != null) {
        // Extract prayer times and additional information from stored data
        prayerTimes_ = storedPrayerTimes.sublist(0, 5).cast<String>();

        dayName = storedPrayerTimes[5];
        gregorianDate = storedPrayerTimes[6];
        gregorianDateDisplay = storedPrayerTimes[7];
        hijriDate = storedPrayerTimes[8];

        // Now you have the prayer times and additional information for the current date
        // You can use this data as needed

        prayerTimes[0] = prayerTimes_[0].split(" ")[0];
        prayerTimes[1] = prayerTimes_[1].split(" ")[0];
        prayerTimes[2] = prayerTimes_[2].split(" ")[0];
        prayerTimes[3] = prayerTimes_[3].split(" ")[0];
        prayerTimes[4] = prayerTimes_[4].split(" ")[0];
      } else {
        throw Exception('No locally saved data found for the current date');
      }
    } catch (e) {
      // Handle errors
    }
  }

  String? getKeyFromValue(Map<String, String> map, String value) {
    for (var entry in map.entries) {
      if (entry.value.trim() == value.trim()) {
        return entry.key;
      }
    }
    return null;
  }

  // Future<void> initializeService() async {
  //   service = FlutterBackgroundService();
  //   isRunning = await service.isRunning();
  //   service_is_runing.value = isRunning;
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       // this will be executed when app is in foreground or background in separated isolate
  //       onStart: onstart,

  //       // auto start service
  //       autoStart: false,
  //       isForegroundMode: true,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       // auto start service
  //       autoStart: false,

  //       // this will be executed when app is in foreground in separated isolate
  //       onForeground: onstart,

  //       // you have to enable background fetch capability on xcode project
  //       //onBackground: onIosBackground,
  //     ),
  //   );
  // }

  Future<void> initializeService() async {
    service = FlutterBackgroundService();
    isRunning = await service.isRunning();
    service_is_runing.value = isRunning;

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ICBC', // id
      'ICBC SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          //iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('yh'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onstart,

        // auto start service
        autoStart: false,
        isForegroundMode: true,

        notificationChannelId: 'ICBC',
        initialNotificationTitle: 'ICBC SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

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

    if (now.hour > int.parse(prayerTimes[4].split(":")[0]) ||
        (now.hour == int.parse(prayerTimes[4].split(":")[0]) &&
            now.minute >= int.parse(prayerTimes[4].split(":")[1]))) {
      index = 1;
    }

    for (var x in prayerTimes) {
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
    final remainingMinutes = closestDiffInMinutes % 60 + 1;

    return [closestKey, hours, remainingMinutes];
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
    } catch (e) {}
  }

  String getPrayerName(int index) {
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

  void updateTime() {
    // Update the current time

    currentTime.value =
        '${addLeadingZero(DateTime.now().hour)} : ${addLeadingZero(DateTime.now().minute)}';
  }
}
