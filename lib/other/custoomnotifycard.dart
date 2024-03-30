import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sametsalah/views/notifications_detialspage.dart';

class CustomNotificationCard extends StatelessWidget {
  const CustomNotificationCard({
    Key? key,
    required this.title,
    required this.body,
    required this.imageurl,
    required this.time,
  }) : super(key: key);

  final String imageurl;
  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsDetialsPageState(
              imageUrl: imageurl,
              title: title,
              text: body,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CircleAvatar(
                  radius: 32.0,
                  backgroundColor: Colors.grey,
                  child: imageurl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageurl,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            backgroundImage: imageProvider,
                            radius: 30.0,
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )
                      : Image.asset(
                          "images/logo_white.png",
                          height: 100,
                          width: 100,
                        ),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                flex: 3,
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    body,
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Text(time),
                  ),
                  contentPadding: EdgeInsets.only(left: 10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
