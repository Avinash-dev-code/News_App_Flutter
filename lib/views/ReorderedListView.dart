import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newsdemoapp/helper/CustomDialog.dart';
import 'package:newsdemoapp/helper/widgets.dart';
import 'package:newsdemoapp/views/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReorderedListView extends StatefulWidget {
  // const ReorderedListView({list =List<CategorieModel>})
  final list;
  final bool isSinglePage;

  const ReorderedListView({Key? key, required this.list, required this.isSinglePage}) : super(key: key);

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

  bool value1 = false;

  @override
  void initState() {
    super.initState();
    // getSP();
    getList();

    debugPrint("widgetList:- ${widget.list.length}");
  }


  void getList() async {
    final prefs = await SharedPreferences.getInstance();
    // ###### to clear SharedPreferences cache  ######
    // await prefs.clear();

    if (prefs.getString('catagoriesList') == null) {
      setState(() {
        _imageUris = widget.list;
        debugPrint("emptyList:- ${widget.list.length}");
      });
    } else {
      // jsonData = jsonDecode(prefs.getString('catagoriesList')!);
      List<dynamic> stringData = [];
      for (dynamic e in jsonDecode(prefs.getString('catagoriesList')!)) {
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
    var newList = [];
    if (tList.isNotEmpty) {
      var enableList =
          tList.where((item) => item["isDisable"] == "false").toList();
      var disableList =
          tList.where((item) => item["isDisable"] == "true").toList();
      newList = [...enableList, ...disableList];
    } else {
      newList = tList;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('catagoriesList', (jsonEncode(newList)));
    debugPrint("shareList:- ${jsonEncode(newList)}");
    getList();
  }

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          final TextEditingController _textEditingController =
              TextEditingController();

          bool? isChecked =
              _imageUris[0]["isDisable"].toString() == "false" ? true : false;
          bool? isChecked2 =
              _imageUris[1]["isDisable"].toString() == "false" ? true : false;
          bool? isChecked3 =
              _imageUris[2]["isDisable"].toString() == "false" ? true : false;

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                content: Form(
              key: _formKey,
              child: ListView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  itemCount: _imageUris.length,
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_imageUris[index]["categorieName"]),
                        Checkbox(
                            value: _imageUris[index]["isDisable"] == "true"
                                ? false
                                : true,
                            onChanged: (checked) {
                              setState(() {
                                isChecked = checked;
                                if (isChecked == true) {
                                  setState(() {
                                    _imageUris[index]["isDisable"] = "false";

                                    // var removeElement =
                                    //     _imageUris.removeAt(0);
                                    // debugPrint(
                                    //     "removeElement:- $removeElement");
                                    // _imageUris.add(removeElement);
                                    // for (dynamic e in _imageUris) {
                                    //   debugPrint("removeList1:- $e");
                                    // }
                                  });

                                  addToSP(_imageUris);
                                  getList();
                                } else {
                                  setState(() {
                                    _imageUris[index]["isDisable"] = "true";
                                  });
                                  var removeElement =
                                      _imageUris.removeAt(index);
                                  debugPrint("removeElement:- $removeElement");
                                  _imageUris.add(removeElement);
                                  for (dynamic e in _imageUris) {
                                    debugPrint("removeList1:- $e");
                                  }
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
                    );
                  }),

            ));
          });
        });
  }

  @override
  Widget build(BuildContext context) {

    return widget.isSinglePage?
    MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Drag And drop Category'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DragAndDropGridView(
                controller: ScrollController(),

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                ),
                padding: EdgeInsets.only(top: 20),
                itemBuilder: (context, index) => Stack(

                    alignment: Alignment.topCenter,
                    children: (<Widget>[
                      if (_imageUris[index]["isDisable"] == "false")
                        Container(
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(right: 14),
                          padding: _imageUris[index]["isDisable"] == "false"
                              ? EdgeInsets.zero
                              : EdgeInsets.all(2),
                          child: Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: _imageUris[index]["imageAssetUrl"],
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


                    ])),
                itemCount: _imageUris.length,

                onWillAccept: (oldIndex, newIndex) {
                  debugPrint("onWillAccept:- $oldIndex $newIndex");
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
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              FloatingActionButton(
                onPressed: () async {
                  await showInformationDialog(context);
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder:
                          (context) =>  HomePage(list: _imageUris,),
                      )
                  );

                },
                child: Icon(Icons.arrow_forward),
                backgroundColor: Colors.blue,

              ),
            ],
          ),


        ),
      ): Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    await showInformationDialog(context);
                  },
                  child: Text("Add")),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () async {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder:
                      (context) =>  HomePage(list: _imageUris,),
                  )
              );

            },
                  child: Text("Go"))
            ],
          ),
          DragAndDropGridView(
            controller: ScrollController(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.1,
            ),
            padding: EdgeInsets.only(top: 20),
            itemBuilder: (context, index) =>
                // Stack(
                // alignment: Alignment.topCenter,
                // children: (<Widget>[
                //   if (_imageUris[index]["isDisable"] == "false")
                //     Container(
                //       alignment: Alignment.topRight,
                //       margin: const EdgeInsets.only(right: 14),
                //       padding: _imageUris[index]["isDisable"] == "false"
                //           ? EdgeInsets.zero
                //           : EdgeInsets.all(2),
                //       child: Stack(
                //         children: <Widget>[
                //           ClipRRect(
                //             borderRadius: BorderRadius.circular(5),
                //             child: CachedNetworkImage(
                //               imageUrl: _imageUris[index]["imageAssetUrl"],
                //               height: 60,
                //               width: 120,
                //               fit: BoxFit.fitWidth,
                //             ),
                //           ),
                //           Container(
                //             alignment: Alignment.center,
                //             height: 60,
                //             width: 120,
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(5),
                //                 color: Colors.black26),
                //             child: Text(
                //               _imageUris[index]["categorieName"],
                //               textAlign: TextAlign.center,
                //               style: const TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.w500),
                //             ),
                //           )
                //         ],
                //       ),
                //     )
                // ])),
            NewsTile(
                imgUrl: "" ?? "",
                title: "avinash" ?? "",
                desc: "avinash" ?? "",
                content: "avinash",
                posturl: "avinash" ?? "",
                publishAt: "" ?? "",
                author: "avinash" ?? ""),
            itemCount: _imageUris.length,
            onWillAccept: (oldIndex, newIndex) {
              debugPrint("onWillAccept:- $oldIndex $newIndex");
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
                debugPrint("updatedList:- ${widget.list[i]["categorieName"]}");
              }

              setState(() {});
            },
          ),
        ]);



    // floatingActionButton: Column(
    //   mainAxisAlignment: MainAxisAlignment.end,
    //
    //   children: [
    //     FloatingActionButton(
    //       onPressed: () async {
    //         await showInformationDialog(context);
    //       },
    //       child: Icon(Icons.add),
    //       backgroundColor: Colors.blue,
    //     ),
    //     SizedBox(height: 10),
    //      FloatingActionButton(
    //         onPressed: () async {
    //           Navigator.pushReplacement(context,
    //               MaterialPageRoute(builder:
    //                   (context) =>  HomePage(list: _imageUris,),
    //               )
    //           );
    //
    //         },
    //         child: Icon(Icons.arrow_forward),
    //         backgroundColor: Colors.blue,
    //
    //     ),
    //   ],
    // ),

    //
    //   ),
    // );
  }
}
