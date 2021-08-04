import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

class CVUMessageComposer extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUMessageComposer({required this.nodeResolver});

  @override
  _CVUMessageComposerState createState() => _CVUMessageComposerState();
}

class _CVUMessageComposerState extends State<CVUMessageComposer> {
  String? composedMessage;

  late final contentController;

  @override
  initState() {
    contentController = TextEditingController(text: composedMessage);
    contentController.addListener(_setComposedMessage);
    super.initState();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  void _setComposedMessage() {
    setState(() => composedMessage = contentController.text);
  }

  bool get canSend => composedMessage?.nullIfBlank != null;

  onPressSend() {
    contentController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1),
        Container(
          color: CVUColor.system("secondarySystemBackground"),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: space(6, [
              Flexible(
                child: TextFormField(
                  controller: contentController,
                  style: TextStyle(backgroundColor: CVUColor.system("systemBackground")),
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: "Type a message...",
                    contentPadding: EdgeInsets.all(5)
                  ),
                ),
              ),
              TextButton(
                  onPressed: canSend ? onPressSend : null, child: Icon(Icons.arrow_circle_up))
            ]),
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
