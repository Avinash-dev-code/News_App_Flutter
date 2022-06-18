import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_share/flutter_share.dart';
import 'dart:io';
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
  double webProgress=0;


  Future<void> share() async {
    await FlutterShare.share(
        title: 'Share Article',
        linkUrl: widget.postUrl,
        chooserTitle: 'Example Chooser Title'
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

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

              initialUrl: widget.postUrl,
              javascriptMode: JavascriptMode.disabled,
              gestureNavigationEnabled: true,
              backgroundColor: const Color(0x00000000),
              
              onProgress: (progress) =>setState((){
               this.webProgress=progress/100;
              }),

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
