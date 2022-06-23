import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WebscoketDemo extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<WebscoketDemo> {
  late WebSocketChannel channel;
  late TextEditingController controller;
  final List<String> list = [];
  var jsonData;
  String Data="";
  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('wss://stream.binance.com:9443/ws/ethusdt@trade');
    controller = TextEditingController();
    List<int> jsonData=[];
    // channel.stream.listen((data) => setState(() async {
    //   final prefs = await SharedPreferences.getInstance();
    //
    //   jsonData.add(jsonDecode(data)['E']);
    //   prefs.setInt('price', jsonDecode(data)['E']);
    //
    //     debugPrint("jsonData:- ${jsonDecode(data)['E']}");
    // }

    // ));
    // getData();
    // jsonData.forEach((element) async {
    //   if (element['E'] != null) {
    //     Text("Etherum:- ${element['E']}");
    //
    //   }
    // })
  }


  void sendData() {
    if (controller.text.isNotEmpty) {
      channel.sink.add(controller.text);
      controller.text = "";
    }
  }

  Future getData() async{
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    setState(() {

    });
  }


  @override
  void deactivate() {
    super.deactivate();
    channel.sink.close();
  }

  @override
  void dispose() {

    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[



       StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                Data=snapshot.data.toString();
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child:Text(snapshot.hasData ? 'Ethereum Price:- ${(jsonDecode(snapshot.data.toString())['p'])}' : '' ,style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
                );
              },

            ),

            // StreamBuilder(
            //   stream: channel.stream,
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     return Container(
            //       child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
            //     );
            //   },
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.send),
      //   onPressed: () {
      //     sendData();
      //   },
      // ),
    );
  }
}