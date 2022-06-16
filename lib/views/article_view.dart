import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:percent_indicator/percent_indicator.dart';
class ArticleView extends StatefulWidget {
  final String postUrl;

   ArticleView({required this.postUrl});

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  bool isLoading=true;
  final key1 = UniqueKey();
  double webProgress=0;


  Future<void> share() async {
    await FlutterShare.share(
        title: 'Share Article',
        linkUrl: widget.postUrl,
        chooserTitle: 'Example Chooser Title'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.black
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              "News",
              style:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
            Text(
              " Now ",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),


          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            highlightColor: Colors.black,
            color: Colors.black,
            onPressed: () {
              share();
            },
          ),
        ],

        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child:Column(
          children: [
             webProgress<1?SizedBox(height:5,
        child: LinearProgressIndicator(
          value: webProgress,
          color: Colors.blue,
          backgroundColor: Colors.black,
        )):SizedBox(),

        Expanded(
            child: WebView(
              key: key1,
              initialUrl: widget.postUrl,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,


              backgroundColor: const Color(0x00000000),
              onProgress: (progress) =>setState((){
               this.webProgress=progress/100;


              }),
              // {
              //   debugPrint('WebView is loading (progress : $progress%)');
              //   CircularPercentIndicator(
              //     radius: 120.0,
              //     lineWidth: 10.0,
              //     animation: true,
              //     percent: progress/100,
              //     center: Text(
              //       progress.toString() + "%",
              //       style: TextStyle(
              //           fontSize: 20.0,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.black),
              //     ),
              //     backgroundColor: Colors.black,
              //     circularStrokeCap: CircularStrokeCap.round,
              //     progressColor: Colors.redAccent,
              //   );
              // },

              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ))
          ],
        )


      ),
    );
  }
}
