import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class EmailViewUIKit extends StatefulWidget {
  final String emailHTML;
  final String? src;

  EmailViewUIKit({this.emailHTML = "", this.src});

  @override
  _EmailViewUIKitState createState() => _EmailViewUIKitState();
}

class _EmailViewUIKitState extends State<EmailViewUIKit> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
        gestureRecognizers: [
          Factory<OneSequenceGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        ].whereType<Factory<OneSequenceGestureRecognizer>>().toSet(),
        initialUrl: 'about:blank',
        onPageFinished: (String url) => _loadContent(),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          var source = (widget.src != null)
              ? widget.src
              : Uri.dataFromString(widget.emailHTML,
                      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
                  .toString();
          _webViewController.loadUrl(source!);
        });
  }

  _loadContent() async {
    var jsURL = "assets/HTMLResources/purify.min.js";
    try {
      var jsContent = await rootBundle.loadString(jsURL);
      await _webViewController.evaluateJavascript(jsContent);
      await _webViewController.evaluateJavascript(getContentLoaderString());
    } catch (e) {
      print(e);
      return;
    }
  }

  String getContentLoaderString() {
    return """
        'use strict';
        var dirty = document.documentElement.outerHTML.toString();
        var clean = DOMPurify.sanitize(dirty, { WHOLE_DOCUMENT: true, RETURN_DOM: true});
        document.documentElement.replaceWith(clean);

        var style = document.createElement('style');
        style.type = 'text/css';
        style.appendChild(document.createTextNode("body { font-family: -apple-system, Helvetica; sans-serif; }"));
        document.getElementsByTagName('head')[0].appendChild(style);
        var metaWidth = document.createElement('meta');
        metaWidth.name = "viewport";
        metaWidth.content = "width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no";
        document.getElementsByTagName('head')[0].appendChild(metaWidth);
       """;
  }
}
