import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/notification_controller.dart';
import 'package:photo_view/photo_view.dart';
// Assuming you have a notification_controllerImp class
//notification_controllerImp controller = Get.put(notification_controllerImp());

class NotificationPage extends StatefulWidget {
  @override
  _NotificationsListPageState createState() => _NotificationsListPageState();
}

late notification_controllerImp controller;

class _NotificationsListPageState extends State<NotificationPage> {
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _streamSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
    print("here2");
  }

  @override
  Widget build(BuildContext context) {
    controller = Get.put(notification_controllerImp());
    return Scaffold(
        appBar: AppBar(
          title: Text("Notifications Page"),
          backgroundColor: Colors.orangeAccent,
        ),
        backgroundColor: Colors.orangeAccent[100],
        body: StreamBuilder<QuerySnapshot>(
          stream:
              controller.notificationsStream, // Replace with your actual stream
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final notifications = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notificationData =
                      notifications[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          if ((notificationData["image_url"] as String)
                              .isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10.0)),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoView(
                                          imageProvider: NetworkImage(
                                              notificationData["image_url"]),
                                        ),
                                      ));
                                },
                                child: Image.network(
                                  notificationData["image_url"] as String,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListTile(
                              title: Text(
                                notificationData["title"] as String,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                notificationData["body"] as String,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator
            }
          },
        ));
  }
}
