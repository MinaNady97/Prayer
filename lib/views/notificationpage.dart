import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sametsalah/controllers/notification_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sametsalah/other/notifications_detials.dart';
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
        body: StreamBuilder<QuerySnapshot>(
          stream: controller
              .get_notifications_from_DB(), // Replace with your actual stream
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final notifications = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notificationData =
                      notifications[index].data() as Map<String, dynamic>;
                  return Custoum_notification_card(
                    image: notifications[index]["image_url"],
                    title: notifications[index]["title"],
                    body: notifications[index]["body"],
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

class Custoum_notification_card extends StatelessWidget {
  const Custoum_notification_card({
    super.key,
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsDetialsPageState(
              imageUrl: image,
              title: title,
              text: body,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!.withOpacity(0.2), // Subtle shadow
              blurRadius: 4.0,
              offset: const Offset(1.0, 2.0),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              // Expand remaining space
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text left
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.black87, // Darker text for better contrast
                      ),
                    ),
                    Flexible(
                      child: Text(
                        body,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (image.isNotEmpty) // Check if image URL is not empty
              Container(
                width: 140.0,
                height: 140.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: image,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
