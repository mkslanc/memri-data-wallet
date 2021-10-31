import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/FileStorageController_shared.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';

class FileDropZone extends StatefulWidget {
  FileDropZone();

  @override
  _FileDropZoneState createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  String message1 = 'Drag & drop your files here or browse to upload.';
  late DropzoneViewController controller1;
  bool highlighted = false;
  List<String> fileNames = [];

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: DottedBorder(
          color: Color(0x80FE570F),
          strokeWidth: 1,
          dashPattern: [10, 10],
          child: Container(
            color: highlighted ? Color(0x1AFE570F) : Colors.transparent,
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
        width: 243,
        child: Padding(
          padding: EdgeInsets.fromLTRB(33, 0, 0, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fileNames
                  .map((e) => Row(
                        children: [
                          Icon(Icons.upload_file),
                          SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child: Text(
                              e,
                              style: CVUFont.bodyTiny.copyWith(overflow: TextOverflow.ellipsis),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      )
    ]);
  }

  Widget buildZone1(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          operation: DragOperation.copy,
          cursor: CursorType.grab,
          onCreated: (ctrl) => controller1 = ctrl,
          onError: (ev) => print('Zone 1 error: $ev'),
          onHover: () {
            setState(() => highlighted = true);
          },
          onLeave: () {
            setState(() => highlighted = false);
          },
          onDrop: (htmlFile) async {
            var fileName = await controller1.getFilename(htmlFile);
            var mime = await controller1.getFileMIME(htmlFile);
            controller1.getFileData(htmlFile).then((value) async {
              await saveFile(mime, fileName, value);
              setState(() {
                highlighted = false;
                fileNames.add(fileName);
              });
            });
          },
        ),
      );

  Future saveFile(String mime, String fileName, Uint8List fileData) async {
    if (mime == "text/plain") {
      await saveText(fileName, fileData);
    } else if (mime.startsWith("image/")) {
      await saveImage(fileName, fileData);
    } else {
      print("Not resolved file type");
    }
  }

  saveImage(String fileName, Uint8List fileData) async {
    var photo = ItemRecord(type: "Photo");
    await photo.save();
    var item = ItemRecord(type: "File");
    var sha256 = FileStorageController.getHashForData(fileData);
    await FileStorageController.writeData(fileData, sha256);
    await item.save();
    await item.setPropertyValue("filename", PropertyDatabaseValueString(fileName));
    await item.setPropertyValue("sha256", PropertyDatabaseValueString(sha256));
    item.fileState = FileState.needsUpload;
    var edge = ItemEdgeRecord(name: "file", sourceRowID: photo.rowId, targetRowID: item.rowId);
    await edge.save();
  }

  saveText(String fileName, Uint8List fileData) async {
    var item = ItemRecord(type: "Note");
    await item.save();
    await item.setPropertyValue("title", PropertyDatabaseValueString(fileName));
    await item.setPropertyValue(
        "content", PropertyDatabaseValueString(Utf8Decoder().convert(fileData)));
  }
}
