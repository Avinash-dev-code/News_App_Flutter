import 'dart:convert';

import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:newsdemoapp/models/categorie_model.dart';
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

  @override
  void initState() {
    super.initState();
    // getSP();
    getList();

    debugPrint("widgetList:- ${ widget.list.length}");
  }

  void getList() async {
    final prefs = await SharedPreferences.getInstance();
    // debugPrint("sharedPr:-${prefs.getString('graphLists2')}");
    if (prefs.getString('graphLists2') == null) {
      setState(() {
        _imageUris = widget.list;
        debugPrint("emptyList:- ${widget.list.length}");
      });
    }
    else {
      // jsonData = jsonDecode(prefs.getString('graphLists2')!);
      List<dynamic> stringData = [];
      for (dynamic e in jsonDecode(prefs.getString('graphLists2')!)) {
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
    prefs.setString('graphLists2', (jsonEncode(tList)));
    debugPrint("shareList:- ${jsonEncode(tList)}");
    getList();
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
            Visibility(
              visible: isAddCategory ? false : true,
              child: DragAndDropGridView(
                controller: ScrollController(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                ),
                padding: EdgeInsets.only(top: 20),
                itemBuilder: (context, index) =>
                    Visibility(
                      visible: _imageUris[index]["isDisable"] == "false"
                          ? true
                          : false,
                      child: Card(
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
                              return Visibility(
                                visible: _imageUris[index]["isDisable"] ==
                                    "false" ? true : false,
                                child: Stack(
                                    children: (<Widget>[
                                      GridTile(
                                          child: CategoryCard(
                                            imageAssetUrl: _imageUris[index]["imageAssetUrl"],
                                            categoryName: _imageUris[index]["categorieName"],)
                                      ),
                                      CloseButton(onPressed: () {
                                        setState(() {
                                          _imageUris[index]["isDisable"] =
                                          "true";
                                          // _imageUris.removeAt(index);

                                        });
                                        addToSP(_imageUris);
                                        getList();
                                        for (dynamic e in _imageUris) {
                                          debugPrint("is clicked:- $e");
                                        }
                                      },
                                        color: Colors.blue,
                                      )
                                    ])
                                ),
                              );
                            },
                          )),
                    ),
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
            ),
            Visibility(
              visible: isAddCategory ? true : false,
              child: Text(_imageUris[0]["categorieName"])
              // ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: _imageUris.length,
              //     shrinkWrap: true,
              //     physics: ClampingScrollPhysics(),
              //     itemBuilder: (context, index) {
              //       return  Text(_imageUris[index]["categorieName"]);
              //       //   Row(
              //       //   children: (<Widget>[
              //       //   Text(_imageUris[index]["categorieName"]),
              //       //   Text(_imageUris[index]["add"]),
              //       //
              //       //
              //       //       ]),
              //       // );
              //     }),
            ),


          ],

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
            setState(() {
              isAddCategory = true;
            });


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
