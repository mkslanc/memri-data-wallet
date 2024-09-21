import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../cvu/controllers/view_context_controller.dart';
import '../../../providers/app_provider.dart';
import 'memri_text_editor_model.dart';

import '../../../utilities/extensions/string.dart';
import 'memri_text_editor_toolbar.dart';

class MemriTextEditor extends StatefulWidget {
  final MemriTextEditorModel Function() model;
  final Function(MemriTextEditorModel) onModelUpdate;
  final ViewContextController viewContext;

  MemriTextEditor({required this.model, required this.onModelUpdate, required this.viewContext});

  @override
  _MemriTextEditorState createState() => _MemriTextEditorState();
}

class _MemriTextEditorState extends State<MemriTextEditor> {
  late final WebViewController _controller;

  var toolbarState = ToolbarState.main;

  late final Future<String> _showHtml;

  late final ValueNotifier<Map<String, dynamic>> currentFormatting;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'textChange',
        onMessageReceived: (JavaScriptMessage message) {
          var model = MemriTextEditorModel.html(message.message);
          widget.onModelUpdate(model);
        },
      )
      ..addJavaScriptChannel(
        'formatChange',
        onMessageReceived: (JavaScriptMessage message) {
          currentFormatting.value = jsonDecode(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: onEditorLoaded,
        ),
      );

    _showHtml = _initShowHtml();
    //TODO: widget.viewContext.searchStringNotifier.addListener(updateSearchState);

    currentFormatting = ValueNotifier(<String, dynamic>{});
  }

  @override
  void dispose() {
    super.dispose();
    //TODO: widget.viewContext.searchStringNotifier.removeListener(updateSearchState);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, provider, _) {
      return FutureBuilder<String>(
        future: _showHtml,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var uri = snapshot.data;
            if (uri != null) {
              _controller.loadFile(uri);
            }

            return Column(
              children: [
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
                if (Provider.of<UIStateProvider>(context, listen: false).isInEditMode)
                  MemriTextEditorToolbar(
                    toolbarState: toolbarState,
                    executeEditorCommand: executeEditorCommand,
                    currentFormatting: currentFormatting,
                  ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children: [
                  Spacer(),
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Spacer(),
                ],
              ),
            );
          }
          return Column();
        },
      );
    });
  }

  void onEditorLoaded(String url) async {
    var initialModel = widget.model();
    setContent(initialModel.html);
    switchEditMode();
    grabFocus();
    //TODO: updateSearchState();
  }

  void grabFocus() {
    _controller.runJavaScript("window.editor.focus();");
  }

  void updateSearchState() {
    /*var script = widget.viewContext.searchString != null
        ? "window.editor.options.editable = true; window.editor.commands.find(\"${widget.viewContext.searchString!.escapeForJavascript()}\"); window.editor.options.editable = ${sceneController.isInEditMode.value};"
        : "window.editor.commands.clearSearch();";
    _controller.runJavaScript(script);*/
  }

  void executeEditorCommand(String format, [Map<String, dynamic>? info]) {
    info ??= {};
    var infoString = jsonEncode(info);
    var script = "window.editor.commands.$format($infoString);";
    _controller.runJavaScript(script);
  }

  Future<String> _initShowHtml() async {
    final tempDir = await getTemporaryDirectory();
    final names = {
      "css": "app.21afb81e.css",
      "jsApp": "app.aa7a2c74.js",
      "jsChunk": "chunk-vendors.cfa982ac.js"
    };

    final htmlPath = join(tempDir.path, 'index.html');
    final cssPath = join(tempDir.path, names["css"]);
    final jsPathApp = join(tempDir.path, names["jsApp"]);
    final jsPathChunk = join(tempDir.path, names["jsChunk"]);

    String css =
        await rootBundle.loadString('assets/noteEditor/noteEditorDist/css/${names["css"]}');
    File(cssPath).writeAsStringSync(css);
    String jsApp =
        await rootBundle.loadString('assets/noteEditor/noteEditorDist/js/${names["jsApp"]}');
    File(jsPathApp).writeAsStringSync(jsApp);
    String jsChunk =
        await rootBundle.loadString('assets/noteEditor/noteEditorDist/js/${names["jsChunk"]}');
    File(jsPathChunk).writeAsStringSync(jsChunk);

    File(htmlPath).writeAsStringSync("""
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset=utf-8>
    <meta name=viewport
    content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
    <title>Text Editor</title>
    <link href=$cssPath rel=preload as=style>
    <link href=$jsPathApp rel=preload as=script>
    <link href=$jsPathChunk rel=preload as=script>
    <link href=$cssPath rel=stylesheet>
    </head>
    <body>
    <noscript><strong>There was an error loading the text editor</strong></noscript>
    <div id=app></div>
    <script src=$jsPathChunk></script>
    <script src=$jsPathApp></script>
    </body>
    </html>
    """);
    return htmlPath;
  }

  void setContent(String? content) async {
    var _content = content?.escapeForJavascript() ?? "";
    _controller.runJavaScript(
        "window.editor.options.content = \"$_content\"; window.editor.view.updateState(window.editor.createState());");
  }

  void switchEditMode() {
    bool isInEditMode = Provider.of<UIStateProvider>(this.context, listen: false).isInEditMode;
    _controller.runJavaScript("window.editor.options.editable = ${isInEditMode};");
    if (!isInEditMode) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }
}

enum ToolbarState { main, color, heading, image }

extension ToolbarStateExtension on ToolbarState {
  bool get showBackButton {
    switch (this) {
      case ToolbarState.main:
      case ToolbarState.image:
        return false;
      default:
        return true;
    }
  }

  ToolbarState onBack() {
    return ToolbarState.main;
  }

  ToolbarState toggleHeading() {
    switch (this) {
      case ToolbarState.heading:
        return ToolbarState.main;
      default:
        return ToolbarState.heading;
    }
  }

  ToolbarState toggleColor() {
    switch (this) {
      case ToolbarState.color:
        return ToolbarState.main;
      default:
        return ToolbarState.color;
    }
  }
}
