import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:photo_view/photo_view.dart';

class NotificationsDetialsPageState extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String text;

  // Custom constructor to receive image, title, and text
  NotificationsDetialsPageState({
    required this.imageUrl,
    required this.title,
    required this.text,
  });

  @override
  _NotificationsListPageState createState() => _NotificationsListPageState();
}

class _NotificationsListPageState extends State<NotificationsDetialsPageState> {
  @override
  Widget build(BuildContext context) {
    double w = Get.width;
    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      appBar: AppBar(
        title: Text("Details Page"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Column(
          children: [
            if (widget.imageUrl.isNotEmpty)
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  width: w,
                  height: screenHeight * 0.5, // Adjust the container height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!.withOpacity(0.2),
                        blurRadius: 4.0,
                        offset: const Offset(1.0, 2.0),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoView(
                            imageProvider: NetworkImage(
                              widget.imageUrl,
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  )),
            // Display the title and body text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.text,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
