import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

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
    var exists = await file.exists();
    if (exists) {
      return file.readAsBytes();
    }
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
      if (await image.exists()) {
        return FileImage(image);
      } else {
        if (uuid != null) {
          return await getImageFromPod(uuid);
        }
      }
    }
  }

  static Future<ImageProvider?> getImageFromPod(String fileSHAHash) async {
    var podService = GetIt.I<PodService>();
    await podService.downloadFile(fileSHAHash);
    var fileURL = await getURLForFile(fileSHAHash);
    var image = File(fileURL);
    if (await image.exists()) {
      return FileImage(image);
    }
  }

  static Future<File> download(String url, String newPath) async {
    var file = File(newPath);
    if (await file.exists()) {
      return file;
    } else {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return await write(newPath, response.bodyBytes);
      } else {
        throw Exception('Failed to download file');
      }
    }
  }

}
