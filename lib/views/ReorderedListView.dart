import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:newsdemoapp/helper/CustomDialog.dart';
import 'package:newsdemoapp/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReorderedListView extends StatefulWidget {

  // const ReorderedListView({list =List<CategorieModel>})
  final list;

  const ReorderedListView({ Key? key, required this.list }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ReorderedListView> {
  var _imageUris = [];

  // final List<String>;
  var list;
  int variableSet = 0;
  late double width;
  late double height;
  late final List<String> jsonData;
  bool isAddCategory = false;
  bool value = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool value1=false;
  @override
  void initState() {
    super.initState();
    // getSP();
    getList();

    debugPrint("widgetList:- ${ widget.list.length}");
  }



  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        //...top circlular image part,
        Container(
          padding: EdgeInsets.only(
            top: 200,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 66.0),
          decoration: new BoxDecoration(
            color: Colors.black, //Colors.black.withOpacity(0.3),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                "title",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "description",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  color: Colors.amber,
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    "buttonText",
                    style: TextStyle(
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              // Implement Circular Image here
            ],
          ),
        ),
      ],
    );
  }





  void getList() async {
    final prefs = await SharedPreferences.getInstance();
    // debugPrint("sharedPr:-${prefs.getString('graphLists3')}");
    if (prefs.getString('graphLists3') == null) {
      setState(() {
        _imageUris = widget.list;
        debugPrint("emptyList:- ${widget.list.length}");
      });
    }
    else {
      // jsonData = jsonDecode(prefs.getString('graphLists3')!);
      List<dynamic> stringData = [];
      for (dynamic e in jsonDecode(prefs.getString('graphLists3')!)) {
        debugPrint("jsonDecodeList:- $e");

        stringData.add(e);
      }
      debugPrint("stringList:- ${stringData.length}");
      setState(() {
        _imageUris = stringData;
      });

      // addToSP(_imageUris);
    }

    debugPrint("imageList:- ${_imageUris.length}");
  }

  Future<void> addToSP(List<dynamic> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('graphLists3', (jsonEncode(tList)));
    debugPrint("shareList:- ${jsonEncode(tList)}");
    getList();
  }
  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(context: context,
        builder: (context){
          final TextEditingController _textEditingController = TextEditingController();
          bool? isChecked = _imageUris[0]["isDisable"].toString()=="false"?true:false;
          bool? isChecked2 = _imageUris[1]["isDisable"].toString()=="false"?true:false;
          bool? isChecked3 = _imageUris[2]["isDisable"].toString()=="false"?true:false;



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
                          Text(_imageUris[0]["categorieName"]),
                          Checkbox(value: isChecked, onChanged: (checked){
                            setState((){
                              isChecked = checked;
                              if(isChecked==true)
                                {
                                  setState(() {
                                    _imageUris[0]["isDisable"] =
                                    "false";

                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();

                                }
                              else
                                {
                                  setState(() {
                                    _imageUris[0]["isDisable"] =
                                    "true";
                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();
                                  for (dynamic e in _imageUris) {
                                    debugPrint("is clicked:- $e");
                                  }
                                }

                              debugPrint("dialogCheck:- ${isChecked}");
                            });
                          })
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_imageUris[1]["categorieName"]),
                          Checkbox(value: isChecked2, onChanged: (checked){
                            setState((){
                              isChecked2 = checked;

                              if(isChecked2==true)
                                {
                                  setState(() {
                                    _imageUris[1]["isDisable"] =
                                    "false";
                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();

                                }
                              else
                                {
                                  setState(() {
                                    _imageUris[1]["isDisable"] =
                                    "true";
                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();
                                  for (dynamic e in _imageUris) {
                                    debugPrint("is clicked:- $e");
                                  }
                                }

                              debugPrint("dialogCheck:- ${isChecked}");
                            });
                          })
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_imageUris[2]["categorieName"]),
                          Checkbox(value: isChecked3, onChanged: (checked){
                            setState((){
                              isChecked3 = checked;

                              if(isChecked3==true)
                                {
                                  setState(() {
                                    _imageUris[2]["isDisable"] =
                                    "false";
                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();

                                }
                              else
                                {
                                  setState(() {
                                    _imageUris[2]["isDisable"] =
                                    "true";
                                    // _imageUris.removeAt(index);

                                  });
                                  addToSP(_imageUris);
                                  getList();
                                  for (dynamic e in _imageUris) {
                                    debugPrint("is clicked:- $e");
                                  }
                                }

                              debugPrint("dialogCheck:- ${isChecked}");
                            });
                          })
                        ],
                      ),

                    ],
                  )),

            );
          });
        });
  }


  @override
  Widget build(BuildContext context) {
    debugPrint("uiList:- ${_imageUris.length}");
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Drag And drop Plugin'),
        ),
        body: Column(
          children: [
              DragAndDropGridView(
                controller: ScrollController(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                ),
                padding: EdgeInsets.only(top: 20),
                itemBuilder: (context, index) =>
                    Card(
                          color: Colors.white,
                          elevation: 0,
                          child: LayoutBuilder(
                            builder: (context, costrains) {
                              if (variableSet == 0) {
                                height = costrains.maxHeight;
                                width = costrains.maxWidth;
                                variableSet++;
                              }
                              // return GridTile(
                              //   child: Image.network(
                              //     widget.list[index]["imageAssetUrl"],
                              //     fit: BoxFit.cover,
                              //     height: height,
                              //     width: width,
                              //   ),
                              // );
                              return  Stack(
                                    children: (<Widget>[

                                  if(_imageUris[index]["isDisable"]=="false")
                                    Container(
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(right: 14),
                                      padding: _imageUris[index]["isDisable"]=="false"?EdgeInsets.zero:EdgeInsets.all(2),
                                      child: Stack(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl:  _imageUris[index]["imageAssetUrl"],
                                              height: 60,
                                              width: 120,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            height: 60,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: Colors.black26),
                                            child: Text(
                                              _imageUris[index]["categorieName"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                    )


                                      // CloseButton(onPressed: () {
                                    
                                      //   addToSP(_imageUris);
                                      //   getList();
                                      //   for (dynamic e in _imageUris) {
                                      //     debugPrint("is clicked:- $e");
                                      //   }
                                      // },
                                      //   color: Colors.blue,
                                      // )
                                    ])
                                );

                            },
                          )),

                itemCount: _imageUris.length,
                onWillAccept: (oldIndex, newIndex) {
                  // Implement you own logic

                  // Example reject the reorder if the moving item's value is something specific
                  if (_imageUris[newIndex] == "something") {
                    return false;
                  }
                  return true; // If you want to accept the child return true or else return false
                },
                onReorder: (oldIndex, newIndex) {
                  final temp = _imageUris[oldIndex];
                  _imageUris[oldIndex] = _imageUris[newIndex];
                  _imageUris[newIndex] = temp;
                  addToSP(_imageUris);

                  getList();


                  // addToSP(_imageUris);

                  // _imageUris.clear();
                  // for(String e in _imageUris)
                  //   {
                  // _imageUris.add(e);
                  // debugPrint("finalList:- $e");
                  //   }
                  for (int i = 0; i < widget.list.length; i++) {
                    debugPrint(
                        "updatedList:- ${widget.list[i]["categorieName"]}");
                  }


                  setState(() {});
                },
              ),


          ],

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {




            await showInformationDialog(context);

                  // var imageDisable = [];
            // for(dynamic e in _imageUris)
            //   {
            //     if(e["isDisable"]=="true")
            //       {
            //
            //         imageDisable.add(e);
            //       }
            //   }
            // for(dynamic e in imageDisable)
            // {
            //
            // debugPrint("image disable:- ${e}");
            // }



            // //2
            // CategorieModel categorieModel2 = new CategorieModel();
            //
            // categorieModel2.categorieName = "Entertainment";
            // categorieModel2.imageAssetUrl = "https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80";
            // category.add(categorieModel2);
            //
            // //3
            // CategorieModel categorieModel3 = new CategorieModel();
            //
            // categorieModel3.categorieName = "General";
            // categorieModel3.imageAssetUrl = "https://images.unsplash.com/photo-1495020689067-958852a7765e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60";
            // category.add(categorieModel3);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
