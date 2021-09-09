import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:moor/moor.dart';
import 'package:crypto/crypto.dart';
import 'package:idb_shim/idb.dart';

/// The FileStorageController class provides methods to store and retrieve files locally
class FileStorageController {
  static const String _dbName = 'files.db';
  static const String _propNameFilePath = 'filePath';
  static const String _propNameFileContents = 'contents';

  static Future<Database> _openDb() async {
    final idbFactory = getIdbFactory();
    if (idbFactory == null) {
      throw Exception('getIdbFactory() failed');
    }
    return idbFactory.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (e) =>
          e.database.createObjectStore(getFileStorageURL(), keyPath: _propNameFilePath),
    );
  }

  static String getURLForFile(String uuid) {
    return getFileStorageURL() + "/" + uuid;
  }

  static getFileStorageURL() {
    return "files";
  }

  static deleteFileStorage() async {
    var db = await _openDb();
    var storageUrl = getFileStorageURL();
    var txn = db.transaction(storageUrl, idbModeReadWrite);
    var store = txn.objectStore(storageUrl);
    await store.clear();
    await txn.completed;
  }

  static Future<bool> fileExists(String path) async {
    var db = await _openDb();
    var storageUrl = getFileStorageURL();
    var txn = db.transaction(storageUrl, idbModeReadOnly);
    var store = txn.objectStore(storageUrl);
    var object = await store.getObject(path);
    await txn.completed;
    return object != null;
  }

  static Future<Uint8List?> getData({String? uuid, String? fileURL}) async {
    fileURL ??= getURLForFile(uuid!);
    var db = await _openDb();
    var storageUrl = getFileStorageURL();
    var txn = db.transaction(storageUrl, idbModeReadOnly);
    var store = txn.objectStore(storageUrl);
    var object = await store.getObject(fileURL) as Map?;
    await txn.completed;
    return object?['contents'] as Uint8List?;
  }

  static Future<ByteData> getByteDataFromAsset(String path) async {
    return await rootBundle.load(path);
  }

  static Future copy(String oldPath, String newPath) async {
    var byteData = await getByteDataFromAsset(oldPath);
    await write(
        newPath, byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  static Future write(String path, Uint8List byteData) async {
    var db = await _openDb();
    var storageUrl = getFileStorageURL();
    var txn = db.transaction(storageUrl, idbModeReadWrite);
    var store = txn.objectStore(storageUrl);
    await store.put({_propNameFilePath: path, _propNameFileContents: byteData});
    await txn.completed;
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
    var fileURL = getURLForFile(uuid);
    await write(fileURL, data);
  }

  static Future<ImageProvider?> getImage({String? uuid, String? fileURL}) async {
    fileURL ??= getURLForFile(uuid!);
    var image = await getData(uuid: uuid, fileURL: fileURL);
    if (image != null) return MemoryImage(image);
    try {
      await rootBundle.load(fileURL);
      return AssetImage(fileURL);
    } catch (_) {
      return null;
    }
  }
}
