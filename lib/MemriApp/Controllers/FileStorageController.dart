import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// The FileStorageController class provides methods to store and retrieve files locally
class FileStorageController {
  static Future<String> getURLForFile(String uuid) async {
    return await getFileStorageURL() + "/" + uuid;
  }

  static Future<Directory> getFileStorage() async {
    var documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    var memriFileURL = documentsDirectory + "/fileStore";
    return (await Directory(memriFileURL).create(recursive: true));
  }

  static getFileStorageURL() async {
    return (await getFileStorage()).path;
  }

  static deleteFileStorage() async {
    (await getFileStorage()).delete(recursive: true);
  }

  static Future<bool> fileExists(String path) async {
    var file = File(path);
    return await file.exists();
  }

  static Future<Uint8List?> getData({String? uuid, String? fileURL}) async {
    fileURL ??= await getURLForFile(uuid!);
    var file = File(fileURL);
    if (await file.exists()) return file.readAsBytes();
  }

  static Future<File> copy(String oldPath, String newPath) async {
    var byteData = await rootBundle.load(oldPath);
    return await write(
        newPath, byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  static Future<File> write(String path, Uint8List byteData) async {
    return await File(
      path,
    ).writeAsBytes(byteData);
  }

  static Future<String> getHashForFile({String? uuid, String? fileURL}) async {
    var data = await getData(uuid: uuid, fileURL: fileURL);
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

  static Future<ImageProvider?> getImage({String? uuid, String? fileURL}) async {
    fileURL ??= await getURLForFile(uuid!);
    try {
      await rootBundle.load(fileURL);
      return AssetImage(fileURL);
    } catch (_) {
      var image = File(fileURL);
      if (await image.exists()) return FileImage(image);
    }
  }
}
