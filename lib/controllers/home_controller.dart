// ignore_for_file: non_constant_identifier_names

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

enum Sky { red, blue }

Map<Sky, Color> skyColors = <Sky, Color>{
  Sky.red: const Color.fromARGB(255, 127, 41, 53),
  Sky.blue: const Color.fromARGB(255, 1, 50, 90),
};

String addLeadingZero(int value) {
  return value.toString().padLeft(2, '0');
}

@pragma('vm:entry-point')
void onstart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final MainController control = await Get.put(MainController());
  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  instance = await SharedPreferences.getInstance();
  var isNotification = true;

  control.isNotification.value = await control.getNotificationVlaue();
  isNotification = control.isNotification.value;

  service.on('stopService').listen((event) async {
    if (control.flag == false) {
      control.enable_sound();
    }
    await service.stopSelf();
  });
  service.on('turnonNotification').listen((event) async {
    isNotification = true;
    instance!.setBool("isNotification", true);
    print("notifivation on");
  });
  service.on('turnoffNotification').listen((event) async {
    print("notifivation off");
    isNotification = false;
    instance!.setBool("isNotification", false);
  });

  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat.EEEE();
  var today = dateFormat.format(now);

  await control.background_service(today);

  await control.background_notification(service, today, now);
  // Calculate the delay until the next minute starts
  int secondsUntilNextMinute = 60 - now.second;
  int millisecondsUntilNextMinute = 1000 - now.millisecond;

  // Set the delay to the next minute
  Duration delay = Duration(
    seconds: secondsUntilNextMinute,
    milliseconds: millisecondsUntilNextMinute,
  );

  Timer(delay, () {
    Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        final now = DateTime.now();
        DateFormat dateFormat = DateFormat.EEEE();
        var today = dateFormat.format(now);

        await control.background_service(today);

        await control.background_notification(service, today, now);
      },
    );
  });
}

class MainController extends GetxController {
  RxBool isDark = true.obs;
  RxBool isRed = true.obs;
  RxBool isNotification = false.obs;
  RxBool service_is_runing = false.obs;
  RxBool homepage_data_changed = true.obs;
  List<QueryDocumentSnapshot> coordinates = [];
  List<String> prayerTimes = List.filled(6, '00:00');
  List<String> prayerTimes_iqama = List.filled(6, '00:00');
  List<String> prayerTimes_Jumuah = List.filled(3, '00:00');
  List<String> prayerTimes_ = List.filled(12, '');
  List<String> prayerTimes_Jumuah_ = List.filled(3, '');
  String formattedDate = "";
  String targetLatitude = "";
  String targetLongitude = "";
  String dayName = "";
  String selectedDayName = "";
  String gregorianDate = "";
  String gregorianDateDisplay = "";
  String hijriDate = "";
  late var isRunning;
  bool flag = true;
  bool data_month_flag = false;
  String first_date = "";
  String last_date = "";
  //List<String> prayerTimes_ = List.filled(5, '');
  String theme_value = "dark";
  bool flag_test = false;
  var currentTime = "".obs;
  late var time_difference_list;
  late var ClosetKey;
  var is_silent = false;
  var silent_timer = 15;
  //List<String> jumuah_times = ["12:00", "13:15", "14:30"];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var primary_dark_color = Color.fromARGB(255, 127, 41, 53).obs;
  var primary_light_color = Color.fromARGB(255, 127, 41, 53).obs;
  int? notification_count;
  RxString theme_color = "red".obs;
  RxInt unreadcount = 0.obs;

  late Sky selectedSky = isRed.isTrue ? Sky.red : Sky.blue;
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

  Future<void> background_service(var today) async {
    late List<Map<String, dynamic>> closetPrayerInfoList;

    print("today is :" + today);
    print(this.dayName);
    if (this.dayName != today) {
      print("new time fetched");
      final now = DateTime.now();
      final String formattedDate =
          '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${addLeadingZero(now.year)}';
      await this.fetchPrayerTimings(formattedDate);
    }
    if (today == "Friday") {
      var prayerTimes = [...this.prayerTimes];
      prayerTimes.removeAt(2);
      prayerTimes.insertAll(2, this.prayerTimes_Jumuah);
      var prayerTimes_iqama = [...this.prayerTimes_iqama];
      prayerTimes_iqama.removeAt(2);
      prayerTimes_iqama.insertAll(2, this.prayerTimes_Jumuah);
      print(prayerTimes);
      closetPrayerInfoList = this.createPrayerInfoList(
          prayerTimes, prayerTimes_iqama, this.getPrayerName_jumaha, 0);
    } else {
      closetPrayerInfoList = this.createPrayerInfoList(
          this.prayerTimes, this.prayerTimes_iqama, this.getPrayerName, 0);
    }

    var ClosestPrayer = this.findClosestPrayerKey(closetPrayerInfoList);
    ClosetKey = ClosestPrayer['key'];

    time_difference_list =
        this.getTimeDifference(closetPrayerInfoList, ClosetKey);

    //var iqama_time = ClosestPrayer['iqamaTime'];

    if (['Jumuah Fisrt Iqama', 'Jumuah Second Iqama', 'Jumuah Third Iqama']
        .contains(ClosetKey)) {
      silent_timer = 45;
    } else {
      silent_timer = 15;
    }

    print(ClosetKey);
    print(silent_timer);
    print(flag);
    if (time_difference_list['iqamaTimeDifferenceInMinutes'] >= 0 &&
        time_difference_list['iqamaTimeDifferenceInMinutes'] <= silent_timer &&
        flag) {
      print("checking");
      is_silent = await this.checkLocation();
      if (is_silent) {
        flag = false;
      }
    } else if (time_difference_list['iqamaTimeDifferenceInMinutes'] >
            silent_timer &&
        flag == false) {
      this.enable_sound();
      flag = true;
    }
  }

  Future<void> background_notification(
    ServiceInstance service,
    var today,
    var now,
  ) async {
    var nextday = 0;
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService() && isNotification == true) {
        if (now.hour > int.parse(this.prayerTimes[5].split(":")[0]) ||
            (now.hour == int.parse(this.prayerTimes[5].split(":")[0]) &&
                now.minute >= int.parse(this.prayerTimes[5].split(":")[1]))) {
          nextday = 1;
        } else {
          nextday = 0;
        }
        var nextPrayerInfoList;
        if (today == "Friday") {
          var prayerTimes = [...this.prayerTimes];
          prayerTimes.removeAt(2);
          prayerTimes.insertAll(2, this.prayerTimes_Jumuah);
          var prayerTimes_iqama = [...this.prayerTimes_iqama];
          prayerTimes_iqama.removeAt(2);
          prayerTimes_iqama.insertAll(2, this.prayerTimes_Jumuah);

          nextPrayerInfoList = this.createPrayerInfoList(prayerTimes,
              prayerTimes_iqama, this.getPrayerName_jumaha, nextday);
        } else {
          nextPrayerInfoList = this.createPrayerInfoList(this.prayerTimes,
              this.prayerTimes_iqama, this.getPrayerName, nextday);
        }

        nextPrayerInfoList.forEach((prayerInfo) {
          print('Prayer: ${prayerInfo['key']}, '
              'Prayer Time: ${prayerInfo['prayerTime']}, '
              'Iqama Time: ${prayerInfo['iqamaTime']}, '
              'Time Difference: ${prayerInfo['timeDifference']} minutes');
        });
        var NextPrayer = this.findNextPrayerKey(nextPrayerInfoList);

        String _content = "initial";
        // try {
        var status;

        if (flag) {
          status = "normal";
        } else {
          status = "silent";
        }
        print("next prayer ${NextPrayer}");

        var next_prayer_key = NextPrayer!["key"];

        var time_differences = await this.getTimeDifference_notification(
            nextPrayerInfoList, next_prayer_key);

        var fixed_string =
            "${next_prayer_key} remains: ${time_differences['prayerTimeDifference']}";
        if (time_difference_list['prayerTimeDifferenceInMinutes'] >= 0 &&
            time_difference_list['iqamaTimeDifferenceInMinutes'] <= 0) {
          _content =
              "${fixed_string} \nthe $ClosetKey aqama after ${time_difference_list['iqamaTimeDifferenceInMinutes'].abs()}m\nand your phone will be silent \nif you within 100m";
        } else if (time_difference_list['prayerTimeDifferenceInMinutes'] >= 0 &&
            time_difference_list['iqamaTimeDifferenceInMinutes'] >= 0 &&
            time_difference_list['iqamaTimeDifferenceInMinutes'] <
                silent_timer) {
          if (status == "silent") {
            _content =
                "${fixed_string}\nyour phone will be normal when $ClosetKey pray finishes after ${silent_timer - time_difference_list['iqamaTimeDifferenceInMinutes']}m";
          } else {
            _content =
                "${fixed_string}\n$ClosetKey pray finishes after ${silent_timer - time_difference_list['iqamaTimeDifferenceInMinutes']}m ";
          }
        } else {
          _content = fixed_string +
              "\nand will be silent after ${time_differences['iqamaTimeDifference']}\nif you within 100m";
        }
        // } catch (e) {
        //   print("here $e");
        // }
        print(_content);
        flutterLocalNotificationsPlugin.show(
          959,
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
    }
  }

  Future<void> debug_method() async {
    final now = DateTime.now();
    DateFormat dateFormat = DateFormat.EEEE();
    var today = dateFormat.format(now);
    late List<Map<String, dynamic>> closetPrayerInfoList;
    var silent_timer = 15;
    print("today is :" + today);
    print(this.dayName);
    if (this.dayName != today) {
      print("new time fetched");
      final now = DateTime.now();
      final String formattedDate =
          '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${addLeadingZero(now.year)}';
      await this.fetchPrayerTimings(formattedDate);
    }
    if (today == "Friday") {
      var prayerTimes = [...this.prayerTimes];
      prayerTimes.removeAt(2);
      prayerTimes.insertAll(2, this.prayerTimes_Jumuah);
      var prayerTimes_iqama = [...this.prayerTimes_iqama];
      prayerTimes_iqama.removeAt(2);
      prayerTimes_iqama.insertAll(2, this.prayerTimes_Jumuah);
      print(prayerTimes);
      closetPrayerInfoList = this.createPrayerInfoList(
          prayerTimes, prayerTimes_iqama, this.getPrayerName_jumaha, 0);
    } else {
      closetPrayerInfoList = this.createPrayerInfoList(
          this.prayerTimes, this.prayerTimes_iqama, this.getPrayerName, 0);
    }

    var ClosestPrayer = this.findClosestPrayerKey(closetPrayerInfoList);
    var ClosetKey = ClosestPrayer['key'];

    var time_difference_list =
        this.getTimeDifference(closetPrayerInfoList, ClosetKey);

    //var iqama_time = ClosestPrayer['iqamaTime'];

    if (['Jumuah Fisrt Iqama', 'Jumuah Second Iqama', 'Jumuah Third Iqama']
        .contains(ClosetKey)) {
      silent_timer = 45;
    } else {
      silent_timer = 15;
    }
    var nextday = 0;

    var min_distance = await this.getmindistance();
    if (now.hour > int.parse(this.prayerTimes[5].split(":")[0]) ||
        (now.hour == int.parse(this.prayerTimes[5].split(":")[0]) &&
            now.minute >= int.parse(this.prayerTimes[5].split(":")[1]))) {
      nextday = 1;
    } else {
      nextday = 0;
    }
    var nextPrayerInfoList;
    if (today == "Friday") {
      var prayerTimes = [...this.prayerTimes];
      prayerTimes.removeAt(2);
      prayerTimes.insertAll(2, this.prayerTimes_Jumuah);
      var prayerTimes_iqama = [...this.prayerTimes_iqama];
      prayerTimes_iqama.removeAt(2);
      prayerTimes_iqama.insertAll(2, this.prayerTimes_Jumuah);

      nextPrayerInfoList = this.createPrayerInfoList(
          prayerTimes, prayerTimes_iqama, this.getPrayerName_jumaha, nextday);
    } else {
      nextPrayerInfoList = this.createPrayerInfoList(this.prayerTimes,
          this.prayerTimes_iqama, this.getPrayerName, nextday);
    }

    nextPrayerInfoList.forEach((prayerInfo) {
      print('Prayer: ${prayerInfo['key']}, '
          'Prayer Time: ${prayerInfo['prayerTime']}, '
          'Iqama Time: ${prayerInfo['iqamaTime']}, '
          'Time Difference: ${prayerInfo['timeDifference']} minutes');
    });
    var NextPrayer = this.findNextPrayerKey(nextPrayerInfoList);

    String _content = "initial";
    try {
      var status;

      if (flag) {
        status = "normal";
      } else {
        status = "silent";
      }
      print("next prayer ${NextPrayer}");

      var next_prayer_key = NextPrayer!["key"];
      var time_differences = await this
          .getTimeDifference_notification(nextPrayerInfoList, next_prayer_key);
      var fixed_string =
          "${next_prayer_key} remains: ${time_differences['prayerTimeDifference']}\nyor distance from ICBC ${min_distance}m\nthe phone now is $status  ";
      if (time_difference_list['prayerTimeDifferenceInMinutes'] >= 0 &&
          time_difference_list['iqamaTimeDifferenceInMinutes'] <= 0) {
        _content =
            "${fixed_string} \nthe $ClosetKey aqama after ${time_difference_list['iqamaTimeDifferenceInMinutes'].abs()}m\nand your phone will be silent \nif you within 100m";
      } else if (time_difference_list['prayerTimeDifferenceInMinutes'] >= 0 &&
          time_difference_list['iqamaTimeDifferenceInMinutes'] >= 0 &&
          time_difference_list['iqamaTimeDifferenceInMinutes'] < silent_timer) {
        if (status == "silent") {
          _content =
              "${fixed_string}\nyour phone will be normal when $ClosetKey pray finishes after ${silent_timer - time_difference_list['iqamaTimeDifferenceInMinutes']}m";
        } else {
          _content =
              "${fixed_string}\n$ClosetKey pray finishes after ${silent_timer - time_difference_list['iqamaTimeDifferenceInMinutes']}m ";
        }
      } else {
        _content = fixed_string +
            "and will be silent after ${time_differences['iqamaTimeDifference']}\nif you within 100m";
      }
    } catch (e) {
      print("here $e");
    }
    print("Debug methods:\n" + _content);
  }

  Future<void> unread_notification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastTimeStr = prefs.getString("lasttime");
    if (lastTimeStr != null) {
      DateTime lastTime =
          DateTime.parse(lastTimeStr); // Parse DateTime from string
      Timestamp readedN =
          Timestamp.fromDate(lastTime); // Convert DateTime to Timestamp

      CollectionReference notificationsCollection =
          FirebaseFirestore.instance.collection('notifications');

      QuerySnapshot snapshot = await notificationsCollection
          .where('timestamp', isGreaterThan: readedN)
          .get();

      unreadcount.value = snapshot.docs.length;
      print("unreadcount");
      print(unreadcount.value);
    } else {
      setthereadednotification();
      unread_notification();
    }
    update();
  }

  void setthereadednotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lasttime", DateTime.now().toString());
    print("number of notification before zero");
    print(unreadcount.value);
    unreadcount.value = 0;
    update();
  }

  // void changeThemeColor(bool value) {
  //   if (value) {
  //     primary_dark_color = Color.fromARGB(255, 127, 41, 53);
  //     primary_light_color = Color.fromARGB(255, 127, 41, 53);
  //     instance!.setBool("isRed", true);
  //     theme_color = "red";
  //   } else if (value) {
  //     print("blue");
  //     primary_dark_color = Color.fromARGB(255, 51, 72, 99);
  //     primary_light_color = Color.fromARGB(255, 1, 50, 90);
  //     instance!.setBool("isRed", false);
  //     theme_color = "blue";
  //   }
  // }

  void turnNotification(bool value) {
    isNotification.value = value;
    if (value) {
      instance!.setBool("isNotification", true);

      service.invoke("turnonNotification");
    } else {
      instance!.setBool("isNotification", false);

      service.invoke("turnoffNotification");
    }
  }

  Future<bool> getTheme() async {
    // Check if instance is not null before trying to get the boolean value
    if (instance != null) {
      // Use ?. operator to safely access methods on nullable types
      return instance!.getBool("isDark") ??
          false; // Use null-aware operator ?? to provide a default value if "isDark" is not found
    } else {
      return false; // Default value assuming dark mode is false if SharedPreferences is not initialized
    }
  }

  Future<bool> getThemeColor() async {
    // Check if instance is not null before trying to get the boolean value
    if (instance != null) {
      // Use ?. operator to safely access methods on nullable types
      return instance!.getBool("isRed") ??
          false; // Use null-aware operator ?? to provide a default value if "isDark" is not found
    } else {
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
      return false; // Default value assuming dark mode is false if SharedPreferences is not initialized
    }
  }

  @override
  Future<void> onInit() async {
    isRed.value = true;
    theme_color.value = "red";
    selectedSky = isRed.isTrue ? Sky.red : Sky.blue;
    //isNotification.value = instance.getBool("isNotification")!;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.instance.subscribeToTopic("users");

    await fcmconfig();
    await get_coordinates_from_DB();
    // Get the current date
    final now = DateTime.now();
    final String formattedDate =
        '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${addLeadingZero(now.year)}';
    await fetchPrayerTimings(formattedDate);
    super.onInit();
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

  Future<void> get_coordinates_from_DB() async {
    QuerySnapshot coordinates_snapshot = await FirebaseFirestore.instance
        .collection(
            "coordinates") // get the colletion buses from database where it conaton station 1
        .get();
    coordinates.clear();
    coordinates.addAll(coordinates_snapshot.docs); // add docs to list
  }

  Future<void> fetchPrayerTimings(String formattedDate) async {
    try {
      // Retrieve prayer timings for the current date from local storage
      final List<dynamic>? storedPrayerTimes =
          await PrayerTimesStorage.getPrayerTimesForDate(formattedDate);

      if (storedPrayerTimes != null) {
        // Extract prayer times and additional information from stored data
        prayerTimes_ = storedPrayerTimes.sublist(0, 12).cast<String>();
        prayerTimes_Jumuah_ = storedPrayerTimes.sublist(16, 19).cast<String>();

        final now_ = DateTime.now();
        final String currentDay =
            '${addLeadingZero(now_.day)}-${addLeadingZero(now_.month)}-${addLeadingZero(now_.year)}';

        print(prayerTimes_);
        if (currentDay == formattedDate) {
          dayName = storedPrayerTimes[12];
          gregorianDate = storedPrayerTimes[13];
          gregorianDateDisplay = storedPrayerTimes[14];
          hijriDate = storedPrayerTimes[15];
        }
        selectedDayName = storedPrayerTimes[12];
        // Now you have the prayer times and additional information for the current date
        // You can use this data as needed

        prayerTimes[0] = prayerTimes_[0].split(" ")[0];
        prayerTimes[1] = prayerTimes_[1].split(" ")[0];
        prayerTimes[2] = prayerTimes_[2].split(" ")[0];
        prayerTimes[3] = prayerTimes_[3].split(" ")[0];
        prayerTimes[4] = prayerTimes_[4].split(" ")[0];
        prayerTimes[5] = prayerTimes_[5].split(" ")[0];

        prayerTimes_iqama[0] = prayerTimes_[6].split(" ")[0];
        prayerTimes_iqama[1] = prayerTimes_[7].split(" ")[0];
        prayerTimes_iqama[2] = prayerTimes_[8].split(" ")[0];
        prayerTimes_iqama[3] = prayerTimes_[9].split(" ")[0];
        prayerTimes_iqama[4] = prayerTimes_[10].split(" ")[0];
        prayerTimes_iqama[5] = prayerTimes_[11].split(" ")[0];

        prayerTimes_Jumuah[0] = prayerTimes_Jumuah_[0];
        prayerTimes_Jumuah[1] = prayerTimes_Jumuah_[1];
        prayerTimes_Jumuah[2] = prayerTimes_Jumuah_[2];
        first_date = storedPrayerTimes[19];
        last_date = storedPrayerTimes[20];
      } else {
        throw Exception('No locally saved data found for the current date');
      }
    } catch (e) {
      // Handle errors
    }
    homepage_data_changed.value = homepage_data_changed.value ? false : true;
    print(homepage_data_changed.value);
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
    //service = FlutterBackgroundService();
    isRunning = await service.isRunning();
    service_is_runing.value = isRunning;
    //print("service is $isRunning");

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ICBC', // id
      'ICBC SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

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
            duration: const Duration(seconds: 10),
          );
        }
      });
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> service_configure() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onstart,

        // auto start service
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,

        notificationChannelId: 'ICBC',
        initialNotificationTitle: 'ICBC',
        initialNotificationContent: 'Service is Running',
        foregroundServiceNotificationId: 959,
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

  // List findClosestPrayerTime() {
  //   final now = DateTime.now();
  //   String closestKey = "Fajr";
  //   int closestDiffInMinutes =
  //       999999999999999999; // Initialize with maximum positive value
  //   var index = 0;

  //   if (now.hour > int.parse(prayerTimes[4].split(":")[0]) ||
  //       (now.hour == int.parse(prayerTimes[4].split(":")[0]) &&
  //           now.minute >= int.parse(prayerTimes[4].split(":")[1]))) {
  //     index = 1;
  //   }

  //   for (var x in prayerTimes) {
  //     final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
  //         .parse('${now.year}-${now.month}-${now.day + index} ${x}');
  //     final timeDiffInMinutes = (prayerTime.difference(now).inMinutes);

  //     // Check if prayer time is in the future (positive difference)
  //     if (timeDiffInMinutes >= 0 && timeDiffInMinutes < closestDiffInMinutes) {
  //       closestKey = x;
  //       closestDiffInMinutes = timeDiffInMinutes;
  //     }
  //   }
  //   // Convert the closest time difference to hours and remaining minutes
  //   final hours = closestDiffInMinutes ~/ 60;
  //   final remainingMinutes = (closestDiffInMinutes % 60);

  //   return [closestKey, hours, remainingMinutes];
  // }

  // List findClosestPrayerTime_abs() {
  //   final now = DateTime.now();
  //   String closestKey = "Fajr";
  //   int closestDiffInMinutes =
  //       999999999999999999; // Initialize with maximum positive value

  //   for (var x in prayerTimes) {
  //     final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
  //         .parse('${now.year}-${now.month}-${now.day} ${x}');
  //     final timeDiffInMinutes = (now.difference(prayerTime).inMinutes);

  //     // Check if prayer time is in the future (positive difference)
  //     if (timeDiffInMinutes >= 0 && timeDiffInMinutes < closestDiffInMinutes) {
  //       closestKey = x;
  //       closestDiffInMinutes = timeDiffInMinutes;
  //     }
  //   }
  //   // Convert the closest time difference to hours and remaining minutes
  //   final hours = closestDiffInMinutes ~/ 60;
  //   final remainingMinutes = closestDiffInMinutes % 60;

  //   return [closestKey, hours, remainingMinutes];
  // }

  // List find_intrval_bet_now__and_PrayerTime(int index) {
  //   final now = DateTime.now();
  //   var sign;
  //   print(index);
  //   final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
  //       .parse('${now.year}-${now.month}-${now.day} ${prayerTimes[index]}');
  //   final timeDiffInMinutes = (now.difference(prayerTime).inMinutes);
  //   if (timeDiffInMinutes < 0) {
  //     sign = "-";
  //   } else {
  //     sign = "+";
  //   }

  //   final hours = timeDiffInMinutes ~/ 60;
  //   final remainingMinutes = timeDiffInMinutes % 60;

  //   return [hours, remainingMinutes, sign];
  // }

  // String find_intrval_bet_now__and_iqamaTime(int index) {
  //   final now = DateTime.now();
  //   var sign;
  //   int _count = 0;
  //   print(index);
  //   if (now.hour > int.parse(prayerTimes[4].split(":")[0]) ||
  //       (now.hour == int.parse(prayerTimes[4].split(":")[0]) &&
  //           now.minute >= int.parse(prayerTimes[4].split(":")[1]))) {
  //     _count = 1;
  //   }
  //   final prayerTime = DateFormat('yyyy-MM-dd HH:mm').parse(
  //       '${now.year}-${now.month}-${now.day + _count} ${prayerTimes_iqama[index]}');
  //   final timeDiffInMinutes = (prayerTime.difference(now).inMinutes);
  //   if (timeDiffInMinutes < 0) {
  //     sign = "-";
  //   } else {
  //     sign = "+";
  //   }

  //   final hours = timeDiffInMinutes ~/ 60;
  //   final remainingMinutes = timeDiffInMinutes % 60;

  //   return "$hours h:$remainingMinutes m";
  // }

  // List findClosestiqamaTime() {
  //   final now = DateTime.now();
  //   String closestKey = "Fajr";
  //   int closestDiffInMinutes =
  //       999999999999999999; // Initialize with maximum positive value
  //   var index = 0;

  //   if (now.hour > int.parse(prayerTimes_iqama[4].split(":")[0]) ||
  //       (now.hour == int.parse(prayerTimes_iqama[4].split(":")[0]) &&
  //           now.minute >= int.parse(prayerTimes_iqama[4].split(":")[1]))) {
  //     index = 1;
  //   }

  //   for (var x in prayerTimes_iqama) {
  //     final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
  //         .parse('${now.year}-${now.month}-${now.day + index} ${x}');
  //     final timeDiffInMinutes = (prayerTime.difference(now).inMinutes);

  //     // Check if prayer time is in the future (positive difference)
  //     if (timeDiffInMinutes >= 0 && timeDiffInMinutes < closestDiffInMinutes) {
  //       closestKey = x;
  //       closestDiffInMinutes = timeDiffInMinutes;
  //     }
  //   }
  //   // Convert the closest time difference to hours and remaining minutes
  //   final hours = closestDiffInMinutes ~/ 60;
  //   final remainingMinutes = (closestDiffInMinutes % 60);

  //   return [closestKey, hours, remainingMinutes];
  // }

  // List find_intrval_bet_iqama__and_PrayerTime(int index) {
  //   final now = DateTime.now();
  //   var sign;
  //   final prayerTime = DateFormat('yyyy-MM-dd HH:mm')
  //       .parse('${now.year}-${now.month}-${now.day} ${prayerTimes[index]}');
  //   final iqamaTime = DateFormat('yyyy-MM-dd HH:mm').parse(
  //       '${now.year}-${now.month}-${now.day} ${prayerTimes_iqama[index]}');
  //   final timeDiffInMinutes = (iqamaTime.difference(prayerTime).inMinutes);

  //   if (timeDiffInMinutes < 0) {
  //     sign = "-";
  //   } else {
  //     sign = "+";
  //   }

  //   final hours = timeDiffInMinutes ~/ 60;
  //   final remainingMinutes = timeDiffInMinutes % 60;

  //   return [hours, remainingMinutes, sign];
  // }

  // Function to handle notification click event
  void handleNotificationClick() {
    // Navigate to NotificationPage
    Get.to(NotificationPage());
    // runApp(MaterialApp(
    //   home: NotificationPage(),
    // ));
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
        if (prayerElements.isNotEmpty) {
          final String firstGregorianDateStr = prayerElements.first
              .findElements('Date')
              .single
              .innerText; // First gregorianDateStr
          final String lastGregorianDateStr = prayerElements.last
              .findElements('Date')
              .single
              .innerText; // Last gregorianDateStr

          // Save the first and last gregorianDateStr in start_date and last_date
          first_date = reverseDateFormat(firstGregorianDateStr);
          last_date = reverseDateFormat(lastGregorianDateStr);
        }

        // Rest of your code for processing prayer timings...
        else {
          throw Exception('Failed to load prayer timings');
        }
        for (var prayerElement in prayerElements) {
          String gregorianDateStr = prayerElement
              .findElements('Date')
              .single
              .innerText; //need to be dd-mm-yyyy

          final DateTime gregorianDate = DateTime.parse(gregorianDateStr);
          gregorianDateStr = reverseDateFormat(gregorianDateStr);
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
            _formatTime(prayerElement.findElements('Sunrise').single.innerText),
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

          final JumuahIqama = _splitHourMinute(
              prayerElement.findElements('JumuahIqama').single.innerText);
          final JumuahIqama_2 = _splitHourMinute(
              prayerElement.findElements('Jumuah2ndIqama').single.innerText);
          final JumuahIqama_3 = _splitHourMinute(
              prayerElement.findElements('Jumuah3rdIqama').single.innerText);

          final List<String> prayerTimes_Jumuah = dayName == "Friday"
              ? [
                  JumuahIqama[0] > 10
                      ? _formatTime(prayerElement
                          .findElements('JumuahIqama')
                          .single
                          .innerText)
                      : _formatTime(_convertTo24HourFormat(prayerElement
                          .findElements('JumuahIqama')
                          .single
                          .innerText)),
                  JumuahIqama_2[0] > 10
                      ? _formatTime(prayerElement
                          .findElements('Jumuah2ndIqama')
                          .single
                          .innerText)
                      : _formatTime(_convertTo24HourFormat(prayerElement
                          .findElements('Jumuah2ndIqama')
                          .single
                          .innerText)),
                  JumuahIqama_3[0] > 10
                      ? _formatTime(prayerElement
                          .findElements('Jumuah3rdIqama')
                          .single
                          .innerText)
                      : _formatTime(_convertTo24HourFormat(prayerElement
                          .findElements('Jumuah3rdIqama')
                          .single
                          .innerText))
                ]
              : ["", "", ""];

          final duhur_time_iqama = _splitHourMinute(
              prayerElement.findElements('DuhurIqama').single.innerText);

          final List<String> prayerTimes_iqama = [
            _formatTime(
                prayerElement.findElements('FajrIqama').single.innerText),
            _formatTime(prayerElement
                .findElements('Sunrise')
                .single
                .innerText), // no need
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
              prayerTimes_Jumuah,
              dayName,
              gregorianDate_display,
              gregorianDate_display,
              hijriDate,
              first_date,
              last_date);
        }
        data_month_flag = true;
      } else {
        throw Exception('Failed to load prayer timings');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getPrayerName(int index) {
    switch (index) {
      case 0:
        return 'Fajr';
      case 1:
        return 'Sunrise';
      case 2:
        return 'Dhuhr';
      case 3:
        return 'Asr';
      case 4:
        return 'Maghrib';
      case 5:
        return 'Isha';
      default:
        return '';
    }
  }

  String getPrayerName_jumaha(int index) {
    switch (index) {
      case 0:
        return 'Fajr';
      case 1:
        return 'Sunrise';
      case 2:
        return 'Jumuah Fisrt Iqama';
      case 3:
        return 'Jumuah Second Iqama';
      case 4:
        return 'Jumuah Third Iqama';
      case 5:
        return 'Asr';
      case 6:
        return 'Maghrib';
      case 7:
        return 'Isha';
      default:
        return '';
    }
  }

  // int getPrayerindex(String name, day) {
  //   if (day == "Friday") {
  //     switch (name) {
  //       case 'Fajr':
  //         return 0;
  //       case 'Jumuah Fisrt Iqama':
  //         return 1;
  //       case 'Jumuah Second Iqama':
  //         return 2;
  //       case 'Jumuah Third Iqama':
  //         return 3;
  //       case 'Asr':
  //         return 4;
  //       case 'Maghrib':
  //         return 5;
  //       case 'Isha':
  //         return 6;
  //       default:
  //         return 0;
  //     }
  //   } else {
  //     switch (name) {
  //       case 'Fajr':
  //         return 0;
  //       case 'Dhuhr':
  //         return 1;
  //       case 'Asr':
  //         return 2;
  //       case 'Maghrib':
  //         return 3;
  //       case 'Isha':
  //         return 4;
  //       default:
  //         return 0;
  //     }
  //   }
  // }

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

  String prayertime_12format(String time) {
    List time_hour_minute = _splitHourMinute(time);
    int hour = time_hour_minute[0];
    int minute = time_hour_minute[1];

    return hour <= 12 && hour != 0
        ? "$time AM"
        : hour == 0
            ? "${'${hour + 12}'}:${(minute < 10) ? '0$minute' : '$minute'} AM"
            : "${hour - 12 < 10 ? '0${hour - 12}' : hour - 12}:${(minute < 10) ? '0$minute' : '$minute'} PM";
  }

  List<Map<String, dynamic>> createPrayerInfoList(
      List<String> prayerTimes,
      List<String> prayerTimesIqama,
      String Function(int) getPrayerName,
      int index) {
    List<Map<String, dynamic>> prayerInfoList = [];
    DateTime currentDate = DateTime.now();
    for (int i = 0; i < prayerTimes.length; i++) {
      String prayerTime =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${(currentDate.day + index).toString().padLeft(2, '0')} ${prayerTimes[i]}';
      String iqamaTime =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${(currentDate.day + index).toString().padLeft(2, '0')} ${prayerTimesIqama[i]}';
      Duration timeDifference =
          DateTime.parse(iqamaTime).difference(DateTime.parse(prayerTime));

      String prayerName = getPrayerName(i);

      prayerInfoList.add({
        'key': prayerName,
        'prayerTime': prayerTime,
        'iqamaTime': iqamaTime,
        'timeDifference': timeDifference.inMinutes // Convert to minutes
      });
    }

    return prayerInfoList;
  }

  Map<String, dynamic> findClosestPrayerKey(
      List<Map<String, dynamic>> prayerInfoList) {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Initialize the index of the closest prayer time as 0
    int closestIndex = 0;

    // Iterate through the prayerInfoList to find the closest prayer time
    for (int i = 1; i < prayerInfoList.length; i++) {
      // Get the prayer time for the current iteration
      DateTime prayerTime = DateTime.parse(prayerInfoList[i]['prayerTime']);

      // Get the prayer time for the closest index
      DateTime closestPrayerTime =
          DateTime.parse(prayerInfoList[closestIndex]['prayerTime']);

      // Compare the difference between the current prayer time and the closest prayer time found so far
      if (currentTime.difference(prayerTime) <
              currentTime.difference(closestPrayerTime) &&
          currentTime.difference(prayerTime) > Duration.zero) {
        closestIndex = i;
      }
    }

    // Return the key of the closest prayer time
    return prayerInfoList[closestIndex];
  }

  Map<String, dynamic>? findNextPrayerKey(
      List<Map<String, dynamic>> prayerInfoList) {
    // Get the current time
    DateTime currentTime = DateTime.now();

    // Initialize the index of the next prayer time as -1
    int nextIndex = -1;

    // Iterate through the prayerInfoList to find the next prayer time
    for (int i = 0; i < prayerInfoList.length; i++) {
      // Get the prayer time for the current iteration
      DateTime prayerTime = DateTime.parse(prayerInfoList[i]['prayerTime']);

      // Calculate the difference between the current prayer time and the current time
      Duration difference = prayerTime.difference(currentTime);

      // Compare the difference to find the smallest positive difference
      if (difference > Duration.zero &&
          (nextIndex == -1 ||
              difference <
                  prayerTime.difference(DateTime.parse(
                      prayerInfoList[nextIndex]['prayerTime'])))) {
        nextIndex = i;
      }
    }

    // Return the key of the next prayer time
    return nextIndex != -1 ? prayerInfoList[nextIndex] : null;
  }

  Map<String, dynamic> getTimeDifference(
      List<Map<String, dynamic>> prayerInfoList, String key) {
    // Find the prayer time info for the given key
    Map<String, dynamic> timeInfo = prayerInfoList.firstWhere(
        (element) => element['key'] == key,
        orElse: () => {'prayerTime': '', 'iqamaTime': ''});

    // Get current time
    DateTime now = DateTime.now();

    // Parse prayer time and iqama time
    DateTime prayerTime = DateTime.parse(timeInfo['prayerTime']);
    DateTime iqamaTime = DateTime.parse(timeInfo['iqamaTime']);

    // Calculate difference in minutes
    Duration prayerTimeDifference = now.difference(prayerTime);
    Duration iqamaTimeDifference = now.difference(iqamaTime);

    // Format difference in "hh:mm"
    String formattedPrayerTimeDifference = formatTime(prayerTimeDifference);
    String formattedIqamaTimeDifference = formatTime(iqamaTimeDifference);

    return {
      'prayerTimeDifference': formattedPrayerTimeDifference,
      'iqamaTimeDifference': formattedIqamaTimeDifference,
      'prayerTimeDifferenceInMinutes': prayerTimeDifference.inMinutes,
      'iqamaTimeDifferenceInMinutes': iqamaTimeDifference.inMinutes,
    };
  }

  Future<Map<String, dynamic>> getTimeDifference_notification(
      List<Map<String, dynamic>> prayerInfoList, String key) async {
    // Find the prayer time info for the given key
    Map<String, dynamic> timeInfo = prayerInfoList.firstWhere(
        (element) => element['key'] == key,
        orElse: () => {'prayerTime': '', 'iqamaTime': ''});

    // Get current time
    DateTime now = DateTime.now();

    // Parse prayer time and iqama time
    DateTime prayerTime = DateTime.parse(timeInfo['prayerTime']);
    DateTime iqamaTime = DateTime.parse(timeInfo['iqamaTime']);

    // Calculate difference in minutes
    Duration prayerTimeDifference = prayerTime.difference(now);
    Duration iqamaTimeDifference = iqamaTime.difference(now);

    // Format difference in "hh:mm"
    String formattedPrayerTimeDifference = formatTime(prayerTimeDifference);
    String formattedIqamaTimeDifference = formatTime(iqamaTimeDifference);
    print("now i will return to function\n" +
        "$formattedPrayerTimeDifference $formattedIqamaTimeDifference ");
    return {
      'prayerTimeDifference': formattedPrayerTimeDifference,
      'iqamaTimeDifference': formattedIqamaTimeDifference,
      'prayerTimeDifferenceInMinutes': prayerTimeDifference.inMinutes + 1,
      'iqamaTimeDifferenceInMinutes': iqamaTimeDifference.inMinutes + 1,
    };
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes';
  }

  String reverseDateFormat(String dateString) {
    final parts = dateString.split('-');

    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }
}
