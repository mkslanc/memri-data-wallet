import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/UI/Components/NoteEditor/MemriTextEditorModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

class MemriTextEditor extends StatelessWidget {
  final Future<MemriTextEditorModel> Function() model;
  final Function(MemriTextEditorModel) onModelUpdate;
  late final WebViewController _controller;

  MemriTextEditor({required this.model, required this.onModelUpdate});

  //var imageSelectionHandler: MemriTextEditorImageSelectionHandler? TODO
  //var fileHandler: MemriWebViewFileHandler? TODO
  //var searchTerm: String? TODO
  //var isEditing: Binding<Bool>? TODO

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _showHtml(),
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
                          onMessageReceived: (JavascriptMessage message) {}),
                      JavascriptChannel(
                          name: 'formatChange',
                          onMessageReceived: (JavascriptMessage message) {})
                    ]),
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      _controller = controller;
                    },
                    onPageFinished: onEditorLoaded,
                  ),
                ),
                TextButton(onPressed: () => executeEditorCommand("bold"), child: Text("B"))
              ],
            );
          }
          return Column();
        });
  }

  onEditorLoaded(url) async {
    var initialModel = await model();
    setContent(initialModel.html);
    //TODO:
    /*
          self.updateToolbar()
      self.updateSearchState().sink {}.store(in: &self.cancellableBag)
      self.grabFocus(takeFirstResponder: false)
     */
  }

  executeEditorCommand(String format) {
    var script = "window.editor.commands.$format('');";
    _controller.evaluateJavascript(script);
  }

  Future<Uri> _showHtml() async {
    final tempDir = await getTemporaryDirectory();
    final names = {
      "css": "app.21afb81e.css",
      "jsApp": "app.8d222583.js",
      "jsChunk": "chunk-vendors.0e5dd11d.js"
    };

    final htmlPath = join(tempDir.path, 'index.html');
    final cssPath = join(tempDir.path, names["css"]);
    final jsPathApp = join(tempDir.path, names["jsApp"]);
    final jsPathChunk = join(tempDir.path, names["jsChunk"]);

    String css = await rootBundle
        .loadString('assets/noteEditor/noteEditorDist/css/${names["css"]}');
    File(cssPath).writeAsStringSync(css);
    String jsApp = await rootBundle
        .loadString('assets/noteEditor/noteEditorDist/js/${names["jsApp"]}');
    File(jsPathApp).writeAsStringSync(jsApp);
    String jsChunk = await rootBundle
        .loadString('assets/noteEditor/noteEditorDist/js/${names["jsChunk"]}');
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
        "window.editor.options.content = \"$_content\"; window.editor.view.updateState(window.editor.createState());");
  }
}
