import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HtmlViewUIKit extends StatefulWidget {
  final String? html;
  final String? src;
  final bool reload;

  HtmlViewUIKit({this.html, this.src, required this.reload});

  @override
  _HtmlViewUIKitState createState() => _HtmlViewUIKitState();
}

class _HtmlViewUIKitState extends State<HtmlViewUIKit> {
  String createdViewId = Uuid().v4();

  @override
  void initState() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) {
      var iframe = html.IFrameElement()..style.border = 'none';
      if (widget.src != null) {
        iframe.src = widget.src;
      } else if (widget.html != null) {
        var content = widget.html! + loadPurifier() + getContentLoaderString();
        if (widget.reload) content += reloadingScript();
        iframe.srcdoc = content;
      }

      return iframe;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: createdViewId,
    );
  }

  String loadPurifier() {
    return "<script src=\"assets/assets/HTMLResources/purify.min.js\"></script>";
  }

  String getContentLoaderString() {
    return """
    <script type="application/javascript">
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
        
    </script>
       """;
  }

  String reloadingScript() {
    return """
    <script type="application/javascript">
        setTimeout(function() {
          location.reload();
        }, 2000);
    </script>
       """;
  }
}
