import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_share/flutter_share.dart';

class ArticleView extends StatefulWidget {
  final String postUrl;

  const ArticleView({required this.postUrl});

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();


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
              "Flutter",
              style:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              maxLines: 1,
            ),
            Text(
              " News ",
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
        child: WebView(
          initialUrl: widget.postUrl,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ),
      ),
    );
  }
}
