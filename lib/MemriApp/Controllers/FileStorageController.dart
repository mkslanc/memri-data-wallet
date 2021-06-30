import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// The FileStorageController class provides methods to store and retrieve files locally
class FileStorageController {
  static Future<String> getURLForFile(String uuid) async {
    // Little hack to make our demo data work
    var split = uuid.split(".");
    var fileExt = split.length > 1 ? split.last : "jpg";
    var fileName = split[0];
    var url = "assets/demoAssets/$fileName.$fileExt";
    try {
      await rootBundle.load(url);
      return url;
    } catch (_) {
      return await getFileStorageURL() + "/" + uuid;
    }
  }

  static getFileStorageURL() async {
    var documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    var memriFileURL = documentsDirectory + "/fileStore";
    return (await Directory(memriFileURL).create(recursive: true)).path;
  }

  static Future<Uint8List?> getData(String uuid) async {
    var fileURL = await getURLForFile(uuid);
    var file = File(fileURL);
    if (await file.exists()) return file.readAsBytes();
  }

  static Future<String> getHashForFile(String uuid) async {
    var data = await getData(uuid);
    if (data == null) {
      return "";
    }
    return getHashForData(data);
  }

  static String getHashForData(Uint8List data) {
    return sha256.convert(data.toList()).toString();
  }

  static writeData(Uint8List data, String uuid) async {
    var fileURL = await getURLForFile(uuid);
    await File(fileURL).writeAsBytes(data.toList());
  }

  static Future<ImageProvider?> getImage(String uuid) async {
    var fileURL = await getURLForFile(uuid);
    try {
      await rootBundle.load(fileURL);
      return AssetImage(fileURL);
    } catch (_) {
      var image = File(fileURL);
      if (await image.exists()) return FileImage(image);
    }
  }
}
