import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sametsalah/PrayerTimesStorage.dart';
import 'package:sametsalah/main.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:http/http.dart' as http;
import 'package:sametsalah/firebase_options.dart';
import 'package:sametsalah/fbnotify.dart';

class MainController extends GetxController {
  RxBool isDark = true.obs;
  RxBool service_is_runing = false.obs;
  List<QueryDocumentSnapshot> constants = [];
  List<QueryDocumentSnapshot> coordinates = [];
  List<String> prayerTimes = List.filled(5, '00:00');
  //List<String> _prayertimes = [];
  // Map<String, String> prayertime = {
  //   'Fajr': "00:00",
  //   'Dhuhr': "00:00",
  //   'Asr': "00:00",
  //   'Maghrib': "00:00",
  //   'Isha': "00:00",
  // };
  String formattedDate = "";
  String targetLatitude = "";
  String targetLongitude = ""; //

  void changeTheme(bool value) {
    isDark.value = value;
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
    await _requestLocationPermission();
    await _requestnotifyPermission();
    fcmcofing();
    await get_times_from_DB();

    await fetchPrayerTimings__();

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

  Future<void> _requestnotifyPermission() async {
    bool? isGranted = await PermissionHandler.permissionsGranted;
    if (!isGranted!) {
      // Opens the Do Not Disturb Access settings to grant the access
      await PermissionHandler.openDoNotDisturbSetting();
    } else {
      print('DoNotDisturb permission granted');
    }
  }

  Future<void> _requestLocationPermission() async {
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

  void checkLocation() async {
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
          } on PlatformException {
            print('Please enable permissions required');
          }
          print("up");
        }
      }
    } catch (e) {
      print("Error getting location: $e");
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
    constants.addAll(times_snapshot.docs);
    QuerySnapshot coordinates_snapshot = await FirebaseFirestore.instance
        .collection(
            "coordinates") // get the colletion buses from database where it conaton station 1
        .get();
    coordinates.addAll(coordinates_snapshot.docs); // add docs to list
  }

  Future<void> fetchPrayerTimings__() async {
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

        final String dayName = storedPrayerTimes[5];
        final String gregorianDate = storedPrayerTimes[6];
        final String gregorianDateDisplay = storedPrayerTimes[7];
        final String hijriDate = storedPrayerTimes[8];

        // Now you have the prayer times and additional information for the current date
        // You can use this data as needed

        prayerTimes[0] = prayerTimes_[0].split(" ")[0];
        prayerTimes[1] = prayerTimes_[1].split(" ")[0];
        prayerTimes[2] = prayerTimes_[2].split(" ")[0];
        prayerTimes[3] = prayerTimes_[3].split(" ")[0];
        prayerTimes[4] = prayerTimes_[4].split(" ")[0];
        print("pppppppppppppppppppppppppp");
      } else {
        throw Exception('No locally saved data found for the current date');
      }
    } catch (e) {
      // Handle errors
    }
  }
}












// Future<void> fetchPrayerTimings() async {
  //   var position = await get_location();
  //   // Get the current date      https://api.aladhan.com/v1/timings/13-03-2024?latitude=30.0512613&longitude=31.3980016
  //   final DateTime now = DateTime.now();
  //   formattedDate =
  //       '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${now.year}';
  //   // var url = 'https://api.aladhan.com/v1/timings/' +
  //   //     formattedDate +
  //   //     '?latitude=' +
  //   //     position.latitude.toString() +
  //   //     '&longitude=' +
  //   //     position.longitude.toString(); ##########url for public app later
  //   var url = 'https://api.aladhan.com/v1/timings/' +
  //       formattedDate +
  //       '?latitude=30.508188279926383&longitude=-97.79224473202267&tune=0,0,0,0,0,0,0,0,0';
  //   print(url);
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     print(response);
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       final Map<String, dynamic> data = responseData['data'];

  //       prayertime['Fajr'] = data['timings']['Fajr'];
  //       prayertime['Dhuhr'] = data['timings']['Dhuhr'];
  //       prayertime['Asr'] = data['timings']['Asr'];
  //       prayertime['Maghrib'] = data['timings']['Maghrib'];
  //       prayertime['Isha'] = data['timings']['Isha'];
  //       // Find the entry corresponding to the current date
  //     } else {
  //       throw Exception('Failed to load prayer timings');
  //     }
  //   } catch (e) {}
  //   print("hereeeeeeeeeeeeeeeeeeeeee2");
  // }
