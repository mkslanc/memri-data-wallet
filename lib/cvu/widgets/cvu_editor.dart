import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/core/apis/pod/pod_requests.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/enum.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/widgets/components/ace_editor/ace_editor.dart';

import '../../utilities/helpers/app_helper.dart';
import '../constants/cvu_font.dart';
import '../controllers/cvu_controller.dart';
import '../controllers/cvu_lookup_controller.dart';
import '../models/cvu_parsed_definition.dart';
import '../services/parsing/cvu_parse_errors.dart';
import '../services/parsing/cvu_validator.dart';

class CVUEditor extends StatefulWidget {
  final String viewDefinition;

  CVUEditor({required this.viewDefinition});

  @override
  State<CVUEditor> createState() => _CVUEditorViewState();
}

class _CVUEditorViewState extends State<CVUEditor> {
  late final AceEditorController controller;

  bool logMode = false;
  bool allowLogMode = true;
  StreamSubscription? logsStream;

  List<CVUParsedDefinition> definitions = [];
  late CVUController cvuController;

  @override
  initState() {
    super.initState();
    controller = AceEditorController(saveCVU, validate: validate);
    cvuController = GetIt.I();
    init();
  }

  @override
  dispose() {
    super.dispose();
    logsStream?.cancel();
    logsStream = null;
  }

  void init() {
    definitions = CVUController.parseCVUString(widget.viewDefinition)
        .compactMap((definition) =>
            cvuController.definitionByQuery(definition.queryStr));

    if (!logMode) initCVU();
  }

  getLogs(PodConfig connection, String id) async {
    if (id == "") {
      controller.updateEditorContent(
          "Please, start plugin before trying to access logs");
    } else {
      var request = PodStandardRequest.getLogsForPluginRun(id);
      var networkCall = await request.execute(connection);
      if (networkCall.statusCode != 200) {
        controller.updateEditorContent(networkCall.statusCode.toString() +
            ' ' +
            networkCall.reasonPhrase!);
      } else {
        var logs = Utf8Decoder().convert(networkCall.bodyBytes);
        var decodedLogs = jsonDecode(logs);
        controller.updateEditorContent(decodedLogs["logs"]);
      }
    }
  }

/*  setLogMode() async {
    var currentConnection = await AppController.shared.podConnectionConfig;
    var pluginRuns = <Item>[]; //TODO get plugin runs
    controller.updateEditorContent("Loading...");
    setState(() {
      logMode = true;

      if (logsStream == null)
        logsStream = Stream.periodic(const Duration(seconds: 3)).listen((_) =>
            getLogs(currentConnection!,
                pluginRuns.isNotEmpty ? pluginRuns.last.id : ""));
    });
  }*/

  setCVUMode() {
    setState(() {
      logMode = false;
      logsStream?.cancel();
      logsStream = null;
      initCVU();
    });
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  List<Map<String, dynamic>> validate(content) {
    List<CVUParsedDefinition> parsed = <CVUParsedDefinition>[];
    try {
      parsed = CVUController.parseCVUString(content);
    } on CVUParseErrors catch (error) {
      var errorString = error.toErrorString(content);
      var resultErrorString =
          errorString.substring(0, min(100, errorString.length));
      if (resultErrorString != errorString) resultErrorString += "...";
      return [
        {
          "type": "error",
          "row": error.token.ln,
          "column": error.token.ch,
          "text": resultErrorString
        }
      ];
    }

    var validator = CVUValidator(lookupController: CVULookupController());
    validator.validate(parsed);

    return (validator.errors + validator.warnings)
        .map((annotation) => {
              "type": annotation.type.inString,
              "row": annotation.row,
              "column": annotation.column,
              "text": annotation.message
            })
        .toList();
  }

  initCVU() {
    var cvuString = definitions
            .map((node) => node.toCVUString(0, "    ", true))
            .join("\n\n")
            .nullIfBlank ??
        "No cvu found to edit";
    controller.updateEditorContent(cvuString);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Color(0xff333333),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!logMode)
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFFE570F),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 13.5)),
                            onPressed: controller.requestEditorData,
                            child: Text(
                              "Save view",
                              style: CVUFont.link
                                  .copyWith(color: Color(0xffF5F5F5)),
                            ),
                          ),
                        if (logMode)
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xFF333333),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 13.5)),
                            onPressed: setCVUMode,
                            child: Text(
                              "Configure UI",
                              style: CVUFont.link
                                  .copyWith(color: Color(0xffE9500F)),
                            ),
                          ),
                        SizedBox(width: 10),
                        if (!logMode)
                          TextButton(
                            onPressed: close,
                            child: Text(
                              "Cancel",
                              style: CVUFont.link
                                  .copyWith(color: Color(0xFF989898)),
                            ),
                          ),
                        Spacer(),
                        if (!logMode)
                          TextButton(
                              onPressed: () {
                                /*TODO regenerate cvu*/
                              },
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  SvgPicture.asset(
                                      "assets/images/rotate_ccw.svg",
                                      color: Color(0xFFFE570F)),
                                  Text("Reset to default",
                                      style: CVUFont.tabList
                                          .copyWith(color: Color(0xffE9500F))),
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
                Container(
                    constraints: BoxConstraints(minHeight: 60),
                    padding: EdgeInsets.all(10),
                    color: Color(0xff202020),
                    child: Wrap(spacing: 10, children: [
                      if (allowLogMode)
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0xff202020),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 13.5)),
                          onPressed: () {}, //TODO:
                          child: Text(
                            "Log",
                            style:
                                CVUFont.link.copyWith(color: Color(0xff7B81FF)),
                          ),
                        ),
                      TextButton(
                        style: TextButton.styleFrom(
                                backgroundColor: Color(0xff4F56FE))
                            .merge(primaryButtonStyle),
                        onPressed: () {
                          /*TODO run app*/
                        },
                        child: Text(
                          "Run your app",
                          style: CVUFont.link
                              .copyWith(color: app.colors.brandWhite),
                        ),
                      ),
                    ]))
              ],
            ),
            Expanded(child: AceEditor(controller)),
          ],
        ),
      );

  saveCVU() async {
    if (definitions.isNotEmpty) {
      cvuController.updateDefinition(content: controller.content);
      setState(() => init());
    }
    //widget.pageController.sceneController.scheduleUIUpdate();
  }

  //TODO:
  close() {}
}
