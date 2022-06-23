import 'dart:convert';

import 'package:flutter/cupertino.dart';

class Rabit extends StatefulWidget {
  final Stream stream;

  const Rabit({ Key? key, required this.stream}) : super(key: key);

  @override
  _RabitState createState() => _RabitState();
}

class _RabitState extends State<Rabit> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
        builder: (context, snapshot) {
          return Text(snapshot.hasData ? 'Ethereum Price:- ${(jsonDecode(snapshot.data.toString())['p'])}' : '' ,textAlign:TextAlign.start,style: TextStyle(fontSize: 16,fontWeight:FontWeight.bold));

        },
    );
  }
}