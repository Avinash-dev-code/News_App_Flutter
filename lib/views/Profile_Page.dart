



import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newsdemoapp/views/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

import 'login_page.dart';

class Profile_Page extends StatefulWidget {
  const Profile_Page({Key? key}) : super(key: key);

  @override
  Profile_Page_State createState() => Profile_Page_State();
}

class Profile_Page_State extends State<Profile_Page> {

  File imageFile = File("");
  var locationMessage = '';
  String latitude = "";
  String longitude = "";
  String userName = "";
  String usersPhoto = "";
  String photo = "";

  showAlertDialog(BuildContext context) {
    // Navigator.of(context, rootNavigator: true).pop('dialog');
    // set up the button

    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Permission',
      desc: 'allow news app to access your camera and storage',
      btnCancelOnPress: () {
        getFromCamera();
      },
      btnCancelText: "Camera",
      btnOkText: "Gallery",
      btnOkOnPress: () {
        getFromGallery();
      },
    ).show();
  }


  @override
  void initState() {
    getImage();
    getName();
  }

  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name")!;
    photo = prefs.getString("photo")!;
    debugPrint("isPhoto:= $userName $photo");
  }

  Future<void> getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usersPhoto = prefs.getString("photo")!;
    debugPrint("Profile Image:- ${usersPhoto}");
  }

  Future<void> savedProfileImage(String profileImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("photo", profileImage);
    debugPrint("cameeraImage:  $profileImage");
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    Geolocator.requestPermission();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.NO_HEADER,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Location Permission',
        desc: 'allow news app to access your location',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Geolocator.openLocationSettings();
        },
      ).show();

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
      Geolocator.openLocationSettings();

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
      locationMessage =
      "${placemarks[0].subLocality},${placemarks[0].locality}";
    });
    return await Geolocator.getCurrentPosition();
  }

  getFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      debugPrint("Camera Image:-  $image");
      setState(() {
        imageFile = File(image.path);
        savedProfileImage(imageFile.path.toString());
        getImage();
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
        savedProfileImage(imageFile.path.toString());
        getImage();
      });
    }
  }






  @override
  Widget build(BuildContext context) {
    return Container(
        height: 500,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.7),
                              BlendMode.dstATop),
                          image: CachedNetworkImageProvider(
                              "https://img.freepik.com/free-vector/flat-geometric-background_23-2149329827.jpg?t=st=1655459147~exp=1655459747~hmac=5c8e9adb11f8f20c68cb5f1b14828c3ae7fbca7706211895af0bffc87fbdcb9b&w=996"),
                          fit: BoxFit.cover)),
                ),
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 130),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            //Do something
                            // getFromCamera();
                            showAlertDialog(context);
                          },
                          child: CircleAvatar(
                              radius: 60,
                              backgroundImage: usersPhoto.contains("https") ? CachedNetworkImageProvider(usersPhoto) : Image.file(File(usersPhoto)).image),
                        ),
                        SizedBox(height: 10),
                        Text(
                          userName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    )),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _determinePosition();
              },
              child: const Text("Get Current Location"),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              locationMessage,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                signOutGoogle();
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: LoginPage()));
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            )
          ],
        ));
  }
}
