import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/FileStorageController_shared.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'dart:html' as html;

class FileDropZone extends StatefulWidget {
  FileDropZone();

  @override
  _FileDropZoneState createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  late DropzoneViewController controller1;
  bool highlighted = false;
  List<Widget> fileNames = [];

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
                buildZone(context),
                Center(
                    child: RichText(
                        text: TextSpan(
                            text: 'Drag & drop your files here or ',
                            style: CVUFont.bodyText1.copyWith(color: Color(0xff989898)),
                            children: [
                      TextSpan(
                          text: 'browse',
                          recognizer: TapGestureRecognizer()..onTap = () => startWebFilePicker(),
                          style: CVUFont.bodyText1.copyWith(color: Color(0xffFE570F))),
                      TextSpan(
                          text: ' to upload.',
                          style: CVUFont.bodyText1.copyWith(color: Color(0xff989898)))
                    ])))
              ],
            ),
          ),
        ),
      ),
      SizedBox(
        width: 243,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.fromLTRB(33, 0, 0, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fileNames,
            ),
          ),
        ),
      )
    ]);
  }

  void startWebFilePicker() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files ?? [];
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final reader = html.FileReader();
        reader.onLoadEnd.listen((event) async {
          saveFile(file.type, file.name, reader.result as Uint8List);
          fileNames.add(displayFileName(file.name, file.type));
          setState(() {});
        });
        reader.onError.listen((event) {
          print('there was an error');
        });
        reader.readAsArrayBuffer(file);
      }
    });
  }

  Widget buildZone(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          operation: DragOperation.copy,
          onCreated: (ctrl) => controller1 = ctrl,
          onError: (ev) => print('Zone error: $ev'),
          onHover: () {
            setState(() => highlighted = true);
          },
          onLeave: () {
            setState(() => highlighted = false);
          },
          onDrop: (htmlFile) async {
            var fileName = await controller1.getFilename(htmlFile);
            var mime = await controller1.getFileMIME(htmlFile);
            var fileData = await controller1.getFileData(htmlFile);
            saveFile(mime, fileName, fileData);
            fileNames.add(displayFileName(fileName, mime));
            setState(() {});
            highlighted = false;
          },
        ),
      );

  Future saveFile(String mime, String fileName, Uint8List fileData) async {
    try {
      if (mime == "text/plain") {
        await saveText(fileName, fileData);
      } else if (mime.startsWith("image/")) {
        await saveImage(fileName, fileData);
      } else {
        print("Not resolved file type");
      }
    } catch (e) {
      print(e);
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

  Widget displayFileName(String fileName, String mimeType) {
    var color =
        (mimeType == "text/plain" || mimeType.startsWith("image/")) ? Colors.black : Colors.red;
    return Row(
      children: [
        Icon(
          Icons.upload_file,
          color: color,
        ),
        SizedBox(
          width: 18,
        ),
        Expanded(
          child: Text(
            fileName,
            style: CVUFont.bodyTiny.copyWith(overflow: TextOverflow.ellipsis, color: color),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
