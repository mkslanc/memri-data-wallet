import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';

class FileDropZone extends StatefulWidget {
  //final ViewContextController viewContext;

  FileDropZone(/*{required this.viewContext}*/);

  @override
  _FileDropZoneState createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  String message1 = 'Drag & drop your files here or browse to upload.';
  late DropzoneViewController controller1;
  bool highlighted1 = false;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: DottedBorder(
          color: Color(0x80FE570F),
          strokeWidth: 1,
          dashPattern: [10, 10],
          child: Container(
            color: highlighted1 ? Colors.red : Colors.transparent,
            child: Stack(
              children: [
                buildZone1(context),
                Center(child: Text(message1)),
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        width: 213,
      )
    ]);
  }

  Widget buildZone1(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          operation: DragOperation.copy,
          cursor: CursorType.grab,
          onCreated: (ctrl) => controller1 = ctrl,
          onLoaded: () => print('Zone 1 loaded'),
          onError: (ev) => print('Zone 1 error: $ev'),
          onHover: () {
            setState(() => highlighted1 = true);
            print('Zone 1 hovered');
          },
          onLeave: () {
            setState(() => highlighted1 = false);
            print('Zone 1 left');
          },
          onDrop: (ev) {
            print('Zone 1 drop: ${ev.name}');
            setState(() {
              message1 = '${ev.name} dropped';
              highlighted1 = false;
            });
          },
        ),
      );
}
