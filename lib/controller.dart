import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:http/http.dart' as http;

class MainController extends GetxController {
  RxBool isDark = true.obs;
  RxBool service_is_runing = false.obs;
  List<String> prayertime = List.filled(5, '');
  String formattedDate = "";
  static const double targetLatitude =
      30.508188279926383; // Replace with your target latitude
  static const double targetLongitude = -97.79224473202267; //

  void changeTheme(bool value) {
    isDark.value = value;
    //update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    _requestLocationPermission();
    _requestnotifyPermission();
    fetchPrayerTimings();
    get_location();
  }

  Future<Position> get_location() async {
    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return _position;
  }

  void change_service_statu(bool value) {
    service_is_runing.value = value;
    print("updated");
    update();
  }

  String addLeadingZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> fetchPrayerTimings() async {
    var position = await get_location();
    // Get the current date      https://api.aladhan.com/v1/timings/13-03-2024?latitude=30.0512613&longitude=31.3980016
    final DateTime now = DateTime.now();
    formattedDate =
        '${addLeadingZero(now.day)}-${addLeadingZero(now.month)}-${now.year}';
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
      prayertime[0] = data['timings']['Fajr'];
      prayertime[1] = data['timings']['Dhuhr'];
      prayertime[2] = data['timings']['Asr'];
      prayertime[3] = data['timings']['Maghrib'];
      prayertime[4] = data['timings']['Isha'];
      // Find the entry corresponding to the current date
    } else {
      throw Exception('Failed to load prayer timings');
    }
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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      double distanceInMeters = await Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          targetLatitude,
          targetLongitude);
      if (distanceInMeters <= 100) {
        try {
          await SoundMode.setSoundMode(RingerModeStatus.silent);
        } on PlatformException {
          print('Please enable permissions required');
        }
        print("up");
// Mute audio
      } else {
        try {
          await SoundMode.setSoundMode(RingerModeStatus.normal);
        } on PlatformException {
          print('Please enable permissions required');
        }
        print("down");
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
}
