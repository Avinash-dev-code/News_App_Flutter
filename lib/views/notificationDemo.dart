import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notificationDemo extends StatefulWidget {
  @override
  notificationDemo1 createState() => notificationDemo1();
}

class notificationDemo1 extends State<notificationDemo> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialisation();
  }

  var fP = FlutterLocalNotificationsPlugin();

  Future<void> initialisation() async {
    var androidSetup = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSetup = IOSInitializationSettings();
    final setupNotification = InitializationSettings(android: androidSetup, iOS: iosSetup);
    await fP.initialize(setupNotification,onSelectNotification: onSelectNotification);

  }


  Future<void> displayingNotification() async {

    var androidDetail = const AndroidNotificationDetails(
      "id",
      "name",
      showProgress: true,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      color: Colors.blue,
      fullScreenIntent: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      playSound: true,
      ticker: 'ticker',

    );
    var iosDetail = IOSNotificationDetails();
    final allDetail =
    NotificationDetails(android: androidDetail, iOS: iosDetail);
    await fP.show(0, "title", "body", allDetail,
        payload: "first notifications");
  }

  void onSelectNotification(String? payload) async{
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
              "Hello Everyone"
          ),
          content: Text(
              "$payload"
          ),
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                displayingNotification();
              },
              color: Colors.blue,
              textColor: Colors.white,
              child: Text("Notification"),
            ),
            Image(image: AssetImage(AppImages.lion))
          ],
        ),
      ),
    );
  }
}
class AppImages {
  static const String imagesPath = "assets/images/";
  static const String lion = "${imagesPath}spider.png";
}