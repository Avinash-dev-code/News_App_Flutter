import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  File imageFile = File("");
  var locationMessage = '';
  String latitude = "";
  String longitude = "";

  // function for getting the current location
  // but before that you need to add this permission!

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;

    // passing this to latitude and longitude strings
    latitude = "$lat";
    longitude = "$long";
    // getNamebyCordinates();
    // if (lat == null || long == null) return double.parse("");

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    debugPrint("location :- $placemarks $latitude  $longitude");
    setState(() {
      locationMessage = "${placemarks[0].locality}";
    });
    return await Geolocator.getCurrentPosition();
  }

  getFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      debugPrint("Camera Image:-  $image");

      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  getFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint("Gallery Image:-  $image");
      // imageFile = File(image.path);
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 18,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(140),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              // imageFile == null || imageFile.path.isEmpty: Image.file(imageFile),

              child: CircleAvatar(
                radius: 60,
                backgroundImage: Image.file(
                  imageFile,
                ).image,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Avinash",
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton(
              onPressed: () {
                _determinePosition();
              },
              child: const Text("Get User Location"),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              locationMessage,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.blue,
              ),
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Column(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            //Do something
                            getFromCamera();
                          },
                          child: const Icon(Icons.camera_alt)),
                      Text(
                        "Camera",
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(width: 50),
                  Column(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            //Do something
                            getFromGallery();
                          },
                          child: const Icon(Icons.add_a_photo)),
                      Text(
                        "Gallery",
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ],
                  ),
                ]))
          ],
        ),
      ),
    );
  }
}
