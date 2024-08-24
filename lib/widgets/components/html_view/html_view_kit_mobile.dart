import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewUIKit extends StatefulWidget {
  final String? html;
  final String? src;
  final bool reload;

  HtmlViewUIKit({this.html, this.src, required this.reload});

  @override
  _HtmlViewUIKitState createState() => _HtmlViewUIKitState();
}

class _HtmlViewUIKitState extends State<HtmlViewUIKit> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) => _loadContent(),
        ),
      );

    if (widget.html != null || widget.src != null) {
      final source = (widget.src != null)
          ? widget.src!
          : Uri.dataFromString(widget.html!,
                  mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
              .toString();
      _webViewController.loadRequest(Uri.parse(source));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _webViewController,
      gestureRecognizers: [
        Factory<OneSequenceGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
      ].toSet(),
    );
  }

  Future<void> _loadContent() async {
    const jsURL = "assets/HTMLResources/purify.min.js";
    try {
      final jsContent = await rootBundle.loadString(jsURL);
      await _webViewController.runJavaScript(jsContent);
      await _webViewController.runJavaScript(getContentLoaderString());
    } catch (e) {
      AppLogger.err(e);
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
