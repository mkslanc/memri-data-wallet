import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/Components/Text/TextField/MemriTextfield.dart';
import 'package:memri/MemriApp/UI/style/light.dart';

import '../../ViewContextController.dart';

class MemriSimpleTextEditor extends StatefulWidget {
  final Future<FutureBinding<String>?> title;
  final Future<FutureBinding<String>?> content;
  final ViewContextController viewContext;

  MemriSimpleTextEditor({required this.title, required this.content, required this.viewContext});

  @override
  _MemriSimpleTextEditorState createState() => _MemriSimpleTextEditorState();
}

class _MemriSimpleTextEditorState extends State<MemriSimpleTextEditor> {
  FutureBinding<String>? contentBinding;
  FutureBinding<String>? titleBinding;

  init() async {
    contentBinding = await widget.content;
    titleBinding = await widget.title;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemriTextField.async(
                  futureBinding: titleBinding,
                  hint: "New note",
                  hintStyle: CVUFont.headline2,
                  isCollapsed: false,
                ),
                Expanded(
                  child: MemriTextField.async(
                    futureBinding: contentBinding,
                    hint: "Type here",
                    isMultiline: true,
                    hintStyle: CVUFont.bodyText2,
                    isCollapsed: false,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        widget.viewContext.pageController.navigateBack();
                        widget.viewContext.pageController.sceneController.mainPageController
                            .topMostContext
                            ?.setupQueryObservation(); //TODO this is workaround: should delete as soon as db streams are implemented correctly
                      },
                      style: primaryButtonStyle,
                      child: Text("Add note"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () async {
                        //TODO: this is wrong, if we are editing note instead of adding new
                        await widget.viewContext.focusedItem!.delete(
                            widget.viewContext.pageController.appController.databaseController);
                        widget.viewContext.pageController.navigateBack();
                        widget.viewContext.pageController.sceneController.mainPageController
                            .topMostContext
                            ?.setupQueryObservation(); //TODO this is workaround: should delete as soon as db streams are implemented correctly
                      },
                      child: Text(
                        "Cancel",
                        style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                      ),
                      style: TextButton.styleFrom(backgroundColor: null, minimumSize: Size(77, 36)),
                    ),
                  ],
                )
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
}
