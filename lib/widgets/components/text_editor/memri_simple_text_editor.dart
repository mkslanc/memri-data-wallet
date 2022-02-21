import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/utils/binding.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';

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
