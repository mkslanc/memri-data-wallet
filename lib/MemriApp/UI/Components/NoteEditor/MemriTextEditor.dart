import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Components/NoteEditor/MemriTextEditorModel.dart';
import 'package:memri/MemriApp/UI/Components/NoteEditor/MemriTextEditorToolbar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import '../../ViewContextController.dart';

class MemriTextEditor extends StatefulWidget {
  final Future<MemriTextEditorModel> Function() model;
  final Function(MemriTextEditorModel) onModelUpdate;
  final ViewContextController viewContext;

  MemriTextEditor({required this.model, required this.onModelUpdate, required this.viewContext});

  @override
  _MemriTextEditorState createState() => _MemriTextEditorState();
}

class _MemriTextEditorState extends State<MemriTextEditor> {
  late final WebViewController _controller;
  SceneController sceneController = SceneController.sceneController;

  late MemriTextEditorToolbar toolBar;

  var toolbarState = ToolbarState.main;

  late final Future<Uri> _showHtml;

  @override
  void initState() {
    super.initState();
    _showHtml = _initShowHtml();
    widget.viewContext.searchStringNotifier.addListener(updateSearchState);
    sceneController.isInEditMode.addListener(switchEditMode);
  }

  @override
  void dispose() {
    super.dispose();
    widget.viewContext.searchStringNotifier.removeListener(updateSearchState);
    sceneController.isInEditMode.removeListener(switchEditMode);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _showHtml,
        builder: (BuildContext context, AsyncSnapshot<Uri> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var uri = snapshot.data;
            return Column(
              children: [
                Expanded(
                  child: WebView(
                    initialUrl: uri?.toString() ?? 'about:blank',
                    javascriptChannels: Set.from([
                      JavascriptChannel(
                          name: 'textChange',
                          onMessageReceived: (JavascriptMessage message) {
                            var model = MemriTextEditorModel.html(message.message);
                            widget.onModelUpdate(model);
                          }),
                      JavascriptChannel(
                          name: 'formatChange',
                          onMessageReceived: (JavascriptMessage message) {
                            toolBar.update(jsonDecode(message.message));
                          })
                    ]),
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      _controller = controller;
                    },
                    onPageFinished: onEditorLoaded,
                  ),
                ),
                if (sceneController.isInEditMode.value) updateToolbar()
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
                  Spacer()
                ],
              ),
            );
          }
          return Column();
        });
  }

  onEditorLoaded(url) async {
    var initialModel = await widget.model();
    setContent(initialModel.html);
    grabFocus();
    updateSearchState();
  }

  grabFocus() {
    _controller.evaluateJavascript("window.editor.focus();");
  }

  updateSearchState() {
    var script = widget.viewContext.searchString != null
        ? "window.editor.options.editable = true; console.log(window.editor.commands); window.editor.commands.find(\"${widget.viewContext.searchString!.escapeForJavascript()}\"); window.editor.options.editable = ${sceneController.isInEditMode.value};"
        : "window.editor.commands.clearSearch();";
    return _controller.evaluateJavascript(script);
  }

  executeEditorCommand(String format, [Map<String, dynamic>? info]) {
    info ??= {};
    var infoString = jsonEncode(info);
    var script = "window.editor.commands.$format($infoString);";
    _controller.evaluateJavascript(script);
  }

  Future<Uri> _initShowHtml() async {
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

    return Uri(scheme: 'file', path: htmlPath);
  }

  setContent(Future<String?> content) async {
    var _content = (await content)?.escapeForJavascript() ?? "";
    _controller.evaluateJavascript(
        "window.editor.options.content = \"$_content\"; window.editor.view.updateState(window.editor.createState()); window.editor.options.editable = false;");
  }

  switchEditMode() {
    setState(() {
      _controller.evaluateJavascript(
          "window.editor.options.editable = ${sceneController.isInEditMode.value};");
      if (!sceneController.isInEditMode.value) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    });
  }

  updateToolbar() {
    toolBar = MemriTextEditorToolbar(
      toolbarState: toolbarState,
      executeEditorCommand: executeEditorCommand,
    );
    return toolBar;
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
