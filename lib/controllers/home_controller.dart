import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:xml/xml.dart' as xml;

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final MainController control = Get.put(MainController());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var isNotification;

  service.on('stopService').listen((event) async {
    await service.stopSelf();
    control.enable_sound();
  });
  service.on('turnonNotification').listen((event) async {
    isNotification = true;
    print("notifivation on");
  });
  service.on('turnoffNotification').listen((event) async {
    print("notifivation off");
    isNotification = false;
  });
  control.isNotification.value = await control.getNotificationVlaue();
  String? key = null;
  var time_interval = 999999999999999999;
  var time_of_aqama_of_current_prayer = 999999999999999999;
  var closest_prayer_time_now = "";
  List closest_prayer_time_now_list = [];
  bool times_get = false;
  var sign;
  String? last_key = "";
  Timer.periodic(
    const Duration(seconds: 20),
    (timer) async {
      closest_prayer_time_now_list = control.findClosestPrayerTime_abs();
      var index = control.prayerTimes.indexOf(closest_prayer_time_now_list[0]);
      closest_prayer_time_now = control.getPrayerName(index);

      if (closest_prayer_time_now_list[1] == 0 &&
          closest_prayer_time_now_list[2] <= 40) {
        key = closest_prayer_time_now;
      }

      print("closest_prayer_time_now $closest_prayer_time_now");
      print("closest_prayer_time_now_in_min $closest_prayer_time_now_list");

      print("key :$key");
      print("last key $last_key");

      if (key != null && key != last_key) {
        List time_interval_list = control
            .find_intrval_bet_now__and_PrayerTime(control.getPrayerindex(key!));
        print("time interval list $time_interval_list");
        sign = time_interval_list[2];
        time_interval = time_interval_list[1];
      }

      print("control flag ${control.flag}");
      print("time interval:" + time_interval.toString());

      if (key != null && control.flag == true && key != last_key) {
        print('The key for the value is: $key');

        time_of_aqama_of_current_prayer =
            control.find_intrval_bet_iqama__and_PrayerTime(index)[1];
        //int.parse(control.constants[0]["times"][key]);
        //print("sign" + sign);
        if (sign == "+" &&
            time_interval >= time_of_aqama_of_current_prayer &&
            time_interval <= time_of_aqama_of_current_prayer + 15) {
          var checkd = await control.checkLocation();
          if (checkd) {
            control.flag = false;
          } else if (time_interval > time_of_aqama_of_current_prayer + 15) {
            control.flag = true;
            last_key = key;
            key = null;
            time_of_aqama_of_current_prayer = 999999999999999999;
            time_interval = 999999999999999999;
            times_get = false;
          }
        }
      } else if (time_interval > time_of_aqama_of_current_prayer + 15 &&
          sign == "+" &&
          control.flag == false) {
        //print("here 2");
        time_of_aqama_of_current_prayer = 999999999999999999;
        control.enable_sound();
        control.flag = true;
        time_interval = 999999999999999999;
        last_key = key;
        key = null;
        times_get = false;
      }
      print("time fo aqama:$time_of_aqama_of_current_prayer");
      print(isNotification);
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService() && isNotification == true) {
          var min_distance = await control.getmindistance();
          List closest_prayer_time = control.findClosestPrayerTime();
          String _content = "";
          try {
            var status;
            var rev_status;
            if (control.flag == false) {
              status = "silent";
              rev_status = "normal";
            } else {
              status = "normal";
              rev_status = "silent";
            }
            var index = control.prayerTimes.indexOf(closest_prayer_time[0]);
            var iqama_time = control.find_intrval_bet_now__and_iqamaTime(index);
            var fixed_string =
                "${control.getPrayerName(index)} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m\nyor distance from ICBC ${min_distance}m\nthe phone now is $status  ";
            if (key != null &&
                time_interval < time_of_aqama_of_current_prayer &&
                sign == "+") {
              _content =
                  "${fixed_string} \n  the $key aqama after ${time_of_aqama_of_current_prayer - time_interval}m\nand your phone will be silent \nif you within 100m";
            } else if (key != null &&
                time_interval > time_of_aqama_of_current_prayer &&
                time_interval < time_of_aqama_of_current_prayer + 15 &&
                sign == "+") {
              _content =
                  "${fixed_string}\n the $key your phone will be normal when pray finishes after ${time_of_aqama_of_current_prayer + 15 - time_interval}m\n ";
            } else {
              _content = fixed_string +
                  " and will be silent after $iqama_time\nif you within 100m";
            }
          } catch (e) {
            print("here");
          }
          print(_content);
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
                importance: Importance.high,
              ),
            ),
            payload: _content,
          );
        }

        // if (await service.isForegroundService() && isNotification == true) {
        //   List closest_prayer_time = control.findClosestPrayerTime();
        //   String _content = "";
        //   try {
        //     var index = control.prayerTimes.indexOf(closest_prayer_time[0]);
        //     if (key != null &&
        //         time_interval < time_of_aqama_of_current_prayer &&
        //         sign == "+") {
        //       _content =
        //           "${control.getPrayerName(index)} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m\n the $key aqama after ${time_of_aqama_of_current_prayer - time_interval}m";
        //     } else {
        //       _content =
        //           "${control.getPrayerName(index)} remains: ${closest_prayer_time[1]}h : ${closest_prayer_time[2]}m";
        //     }
        //   } catch (e) {
        //     print("here");
        //   }
        //   flutterLocalNotificationsPlugin.show(
        //     888,
        //     'ICBC',
        //     _content,
        //     const NotificationDetails(
        //       android: AndroidNotificationDetails(
        //         'ICBC',
        //         'ICBC SERVICE',
        //         icon: 'yh',
        //         ongoing: true,
        //       ),
        //     ),
        //   );
        // }
      }
    },
  );
}

class MainController extends GetxController {
  RxBool isDark = true.obs;
  RxBool isNotification = true.obs;
  RxBool service_is_runing = false.obs;
  List<QueryDocumentSnapshot> constants = [];
  List<QueryDocumentSnapshot> coordinates = [];
  List<String> prayerTimes = List.filled(5, '00:00');
  List<String> prayerTimes_iqama = List.filled(5, '00:00');
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
  //late SharedPreferences instance;
  List<String> prayerTimes_ = List.filled(5, '');
  String theme_value = "dark";
  bool flag_test = false;
  var currentTime = "".obs;
  String theme_color = "red";
  // Color primary_dark_color = Color.fromARGB(255, 51, 72, 99);
  // Color primary_light_color = Color.fromARGB(255, 1, 50, 90);
  Color primary_dark_color = Color.fromARGB(255, 127, 41, 53);
  Color primary_light_color = Color.fromARGB(255, 127, 41, 53);

  void changeTheme(bool value) {
    isDark.value = value;
    if (value) {
      theme_value = "dark";
      instance!.setBool("isDark", true);
    } else {
      theme_value = "light";
      instance!.setBool("isDark", false);
    }
  }

  void changeThemeColor(String value) {
    if (value == "red") {
      primary_dark_color = Color.fromARGB(255, 127, 41, 53);
      primary_light_color = Color.fromARGB(255, 127, 41, 53);
    } else if (value == "blue") {
      print("blue");
      primary_dark_color = Color.fromARGB(255, 51, 72, 99);
      primary_light_color = Color.fromARGB(255, 1, 50, 90);
    }
    theme_color = value;
  }

  void turnNotification(bool value) {
    isNotification.value = value;
    if (value) {
      print("111111111111111111111");
      instance!.setBool("isNotification", true);
      print("2222222222222222222222222");
      service.invoke("turnonNotification");
      print("3333333333333333333333333");
    } else {
      print("44444444444444444444444");
      instance!.setBool("isNotification", false);
      print("5555555555555555555555555");
      service.invoke("turnoffNotification");
      print("666666666666666666");
    }
  }

  Future<bool> getTheme() async {
    // Check if instance is not null before trying to get the boolean value
    if (instance != null) {
      // Use ?. operator to safely access methods on nullable types
      return instance!.getBool("isDark") ??
          false; // Use null-aware operator ?? to provide a default value if "isDark" is not found
    } else {
      // Handle the case where instance is null
      // You might want to return a default value or throw an error, depending on your use case
      return false; // Default value assuming dark mode is false if SharedPreferences is not initialized
    }
  }

  Future<bool> getNotificationVlaue() async {
    // Check if instance is not null before trying to get the boolean value
    if (instance != null) {
      // Use ?. operator to safely access methods on nullable types
      return instance!.getBool("isNotification") ??
          false; // Use null-aware operator ?? to provide a default value if "isDark" is not found
    } else {
      // Handle the case where instance is null
      // You might want to return a default value or throw an error, depending on your use case
      return false; // Default value assuming dark mode is false if SharedPreferences is not initialized
    }
  }

  @override
  Future<void> onInit() async {
    print("first");
    //isNotification.value = instance.getBool("isNotification")!;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.instance.subscribeToTopic("users");

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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      for (var location in coordinates) {
        targetLatitude = location["lat"];
        targetLongitude = location["long"];
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
            // Get.snackbar(
            //   'permissions', // Title of the snackbar
            //   'Please enable Dontditrub required', // Message of the snackbar
            //   snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
            //   backgroundColor:
            //       Colors.grey[800], // Background color of the snackbar
            //   colorText: Colors.white, // Text color of the snackbar
            //   duration: Duration(seconds: 3),
            // );
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

  Future<int?> getmindistance() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double minDistance = double.infinity;
      for (var location in coordinates) {
        double targetLatitude = double.parse(location["lat"]);
        double targetLongitude = double.parse(location["long"]);

        double distanceInMeters = await Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          targetLatitude,
          targetLongitude,
        );

        minDistance = min(minDistance, distanceInMeters);
      }
      return minDistance.toInt();
    } catch (e) {
      print("Error getting location: $e");
      return null;
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
        prayerTimes_ = storedPrayerTimes.sublist(0, 10).cast<String>();
        print("bfddbfdbffcbcvbvbvbcvbcvbvcbcvbcvcb");
        print(prayerTimes_);

        dayName = storedPrayerTimes[10];
        gregorianDate = storedPrayerTimes[11];
        gregorianDateDisplay = storedPrayerTimes[12];
        hijriDate = storedPrayerTimes[13];

        // Now you have the prayer times and additional information for the current date
        // You can use this data as needed

        prayerTimes[0] = prayerTimes_[0].split(" ")[0];
        prayerTimes[1] = prayerTimes_[1].split(" ")[0];
        prayerTimes[2] = prayerTimes_[2].split(" ")[0];
        prayerTimes[3] = prayerTimes_[3].split(" ")[0];
        prayerTimes[4] = prayerTimes_[4].split(" ")[0];

        prayerTimes_iqama[0] = prayerTimes_[5].split(" ")[0];
        prayerTimes_iqama[1] = prayerTimes_[6].split(" ")[0];
        prayerTimes_iqama[2] = prayerTimes_[7].split(" ")[0];
        prayerTimes_iqama[3] = prayerTimes_[8].split(" ")[0];
        prayerTimes_iqama[4] = prayerTimes_[9].split(" ")[0];
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
          ), onDidReceiveNotificationResponse:
              (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          debugPrint('Notification payload: ${notificationResponse.payload}');
          // Show snackbar with payload
          Get.snackbar(
            'Alert', // Title of the snackbar
            notificationResponse.payload.toString(), // Message of the snackbar
            snackPosition: SnackPosition.TOP, // Position of the snackbar
            backgroundColor:
                Colors.grey[800], // Background color of the snackbar
            colorText: Colors.white, // Text color of the snackbar
            duration: Duration(seconds: 10),
          );
        }
      });
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
    String closestKey = "Fajr";
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
      if (timeDiffInMinutes >= 0 && timeDiffInMinutes < closestDiffInMinutes) {
        closestKey = x;
        closestDiffInMinutes = timeDiffInMinutes;
      }
    }
    // Convert the closest time difference to hours and remaining minutes
    final hours = closestDiffInMinutes ~/ 60;
    final remainingMinutes = (closestDiffInMinutes % 60);

    return [closestKey, hours, remainingMinutes];
  }

  List findClosestPrayerTime_abs() {
    final now = DateTime.now();
    String closestKey = "Fajr";
    int closestDiffInMinutes =
        999999999999999999; // Initialize with maximum positive value

    // if (now.hour > int.parse(prayerTimes[4].split(":")[0]) ||
    //     (now.hour == int.parse(prayerTimes[4].split(":")[0]) &&
    //         now.minute >= int.parse(prayerTimes[4].split(":")[1]))) {
    //   index = 1;
    // }

    for (var x in prayerTimes) {
      final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
          .parse('${now.year}-${now.month}-${now.day} ${x}');
      final timeDiffInMinutes = (prayerTime.difference(now).inMinutes.abs());

      // Check if prayer time is in the future (positive difference)
      if (timeDiffInMinutes >= 0 && timeDiffInMinutes < closestDiffInMinutes) {
        closestKey = x;
        closestDiffInMinutes = timeDiffInMinutes;
      }
    }
    // Convert the closest time difference to hours and remaining minutes
    final hours = closestDiffInMinutes ~/ 60;
    final remainingMinutes = closestDiffInMinutes % 60;

    return [closestKey, hours, remainingMinutes];
  }

  List find_intrval_bet_now__and_PrayerTime(int index) {
    final now = DateTime.now();
    var sign;
    print(index);
    final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('${now.year}-${now.month}-${now.day} ${prayerTimes[index]}');
    final timeDiffInMinutes = (now.difference(prayerTime).inMinutes);
    if (timeDiffInMinutes < 0) {
      sign = "-";
    } else {
      sign = "+";
    }

    final hours = timeDiffInMinutes ~/ 60;
    final remainingMinutes = timeDiffInMinutes % 60;

    return [hours, remainingMinutes, sign];
  }

  String find_intrval_bet_now__and_iqamaTime(int index) {
    final now = DateTime.now();
    var sign;
    print(index);
    final prayerTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        '${now.year}-${now.month}-${now.day} ${prayerTimes_iqama[index]}');
    final timeDiffInMinutes = (prayerTime.difference(now).inMinutes);
    if (timeDiffInMinutes < 0) {
      sign = "-";
    } else {
      sign = "+";
    }

    final hours = timeDiffInMinutes ~/ 60;
    final remainingMinutes = timeDiffInMinutes % 60;

    return "$hours h:$remainingMinutes m";
  }

  List find_intrval_bet_iqama__and_PrayerTime(int index) {
    final now = DateTime.now();
    var sign;
    final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('${now.year}-${now.month}-${now.day} ${prayerTimes[index]}');
    final iqamaTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        '${now.year}-${now.month}-${now.day} ${prayerTimes_iqama[index]}');
    final timeDiffInMinutes = (iqamaTime.difference(prayerTime).inMinutes);

    if (timeDiffInMinutes < 0) {
      sign = "-";
    } else {
      sign = "+";
    }

    final hours = timeDiffInMinutes ~/ 60;
    final remainingMinutes = timeDiffInMinutes % 60;

    return [hours, remainingMinutes, sign];
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
        'https://iqamatime.com/members/icbrushycreek-gmail/TimingsXML.xml';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.body);
        final List<xml.XmlElement> prayerElements =
            xmlDoc.findAllElements('iqama').toList();
        print("fgfhjhjfjfhjfkjfjhjkjhjfkf");
        print(prayerElements.length);
        for (var prayerElement in prayerElements) {
          String gregorianDateStr = prayerElement
              .findElements('Date')
              .single
              .innerText; //need to be dd-mm-yyyy

          final DateTime gregorianDate = DateTime.parse(gregorianDateStr);
          gregorianDateStr = _reverseDateFormat(gregorianDateStr);
          print(gregorianDateStr);

          final String dayName = DateFormat('EEEE').format(gregorianDate);
          final String gregorianDate_display =
              DateFormat('d MMMM yyyy').format(gregorianDate);
          final String hijriDate =
              '${prayerElement.findElements('hijrimonth').single.innerText} ${prayerElement.findElements('hijridate').single.innerText} ${prayerElement.findElements('hijriyear').single.innerText}';
          print(hijriDate);

          final duhur_time = _splitHourMinute(
              prayerElement.findElements('DuhurStart').single.innerText);
          print(duhur_time[0]);

          final List<String> prayerTimes = [
            _formatTime(
                prayerElement.findElements('FajrStart').single.innerText),
            duhur_time[0] > 10
                ? _formatTime(
                    prayerElement.findElements('DuhurStart').single.innerText)
                : _formatTime(_convertTo24HourFormat(
                    prayerElement.findElements('DuhurStart').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('AsrStartS').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('SunsetPlus').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('IshaStart').single.innerText)),
          ];

          final duhur_time_iqama = _splitHourMinute(
              prayerElement.findElements('DuhurIqama').single.innerText);

          final List<String> prayerTimes_iqama = [
            _formatTime(
                prayerElement.findElements('FajrIqama').single.innerText),
            duhur_time_iqama[0] > 10
                ? _formatTime(
                    prayerElement.findElements('DuhurIqama').single.innerText)
                : _formatTime(_convertTo24HourFormat(
                    prayerElement.findElements('DuhurIqama').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('AsrIqama').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('MaghribIqama').single.innerText)),
            _formatTime(_convertTo24HourFormat(
                prayerElement.findElements('IshaIqama').single.innerText)),
          ];

          // Save prayer times and additional information for the current date locally
          await PrayerTimesStorage.savePrayerTimesForDate(
              gregorianDateStr,
              prayerTimes,
              prayerTimes_iqama,
              dayName,
              gregorianDate_display,
              gregorianDate_display,
              hijriDate);
        }
        data_month_flag = true;
      } else {
        throw Exception('Failed to load prayer timings');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _reverseDateFormat(String dateString) {
    final parts = dateString.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final paddedHour = parts[0].padLeft(2, '0');
    final paddedMinute = parts[1].padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  _splitHourMinute(String time) {
    var time_list = List<int>.filled(2, 0);
    ;
    final parts = time.split(':');
    time_list[0] = int.parse(parts[0]);
    time_list[1] = int.parse(parts[1]);
    return time_list;
  }

  String _convertTo24HourFormat(String time) {
    final time_list = _splitHourMinute(time);
    final hour = time_list[0];
    final minute = time_list[1];
    return '${hour + 12}:$minute';
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

  int getPrayerindex(String name) {
    switch (name) {
      case 'Fajr':
        return 0;
      case 'Dhuhr':
        return 1;
      case 'Asr':
        return 2;
      case 'Maghrib':
        return 3;
      case 'Isha':
        return 4;
      default:
        return 0;
    }
  }

  void updateTime() {
    // Update the current time

    currentTime.value =
        '${addLeadingZero(DateTime.now().hour)} : ${addLeadingZero(DateTime.now().minute)}';
  }

  Future<void> stop_battary_obtimized() async {
    try {
      bool? isBatteryOptimizationDisabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      if (isBatteryOptimizationDisabled == false) {
        await DisableBatteryOptimization
            .showDisableBatteryOptimizationSettings();
      }
    } catch (e) {}
  }
}
