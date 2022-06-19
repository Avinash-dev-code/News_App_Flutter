import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CustomDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(context: context,
        builder: (context){
          final TextEditingController _textEditingController = TextEditingController();
          bool? isChecked = false;
          return StatefulBuilder(builder: (context,setState){
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Choice Box"),
                          Checkbox(value: isChecked, onChanged: (checked){
                            setState((){
                              isChecked = checked;
                            });
                          })
                        ],
                      )
                    ],
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text('Okay'),
                  onPressed: (){
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stateful Dialog"),
      ),
      body: Container(
        child: Center(
          child: FlatButton(
              color: Colors.deepOrange,
              onPressed: () async {
                await showInformationDialog(context);
              },
              child: Text(
                "Stateful Dialog",
                style: TextStyle(color: Colors.white, fontSize: 16),
              )),
        ),
      ),
    );
  }
}