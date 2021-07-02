import 'dart:convert';

import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:uuid/uuid.dart';
import 'package:memri/MemriApp/Model/Database.dart';

import '../AppController.dart';

/// This class stores the settings used in the memri app. Settings may include things like how to format dates, whether to show certain
/// buttons by default, etc.
class Settings {
  /// Shared settings that can be used from the main thread
  static var shared = Settings();

  Map<String, List<Uuid>> _listeners = {};
  Map<Uuid, void Function(dynamic)> _callbacks = {};

  // TODO: Refactor this so that the default settings are always used if not found in Realm.
  // Otherwise anytime we add a new setting the get function will return nil instead of the default

  /// Get setting from path
  /// - Parameter path: path of the setting
  /// - Returns: setting value
  Future<T?> get<T>(String path) async {
    try {
      for (var path in _getSearchPaths(path)) {
        T? value = await getSetting<T>(path);
        if (value != null) {
          return value;
        }
      }
    } catch (error) {
      print("Could not fetch setting '$path': $error");
    }

    return null;
  }

  /// get settings from path as String
  /// - Parameter path: path of the setting
  /// - Returns: setting value as String
  Future<String> getString(String path) async {
    return await get<String>(path) ?? "";
  }

  /// get settings from path as Bool
  /// - Parameter path: path of the setting
  /// - Returns: setting value as Bool
  Future<bool?> getBool(String path) async {
    return await get<bool>(path) ?? null;
  }

  /// get settings from path as Int
  /// - Parameter path: path of the setting
  /// - Returns: setting value as Int
  Future<int?> getInt(String path) async {
    return await get<int>(path) ?? null;
  }

  List<String> _getSearchPaths(String path) {
    var p = path[0] == "/" ? path.substring(path.length - 1) : path;
    var splits = p.split("/");
    var type = splits[0];
    var query = splits.sublist(1).join("/");

    /*if (type == "device") {
      return ["\(try Cache.getDeviceID())/\(query)", "defaults/\(query)"];
    }
    else */
    if (type == "user") {
      return ["user/$query", "defaults/$query"];
    } else {
      return ["defaults/$query"];
    }
  }

  /// Sets the value of a setting for the given path. Also responsible for saving the setting to the permanent storage
  /// - Parameters:
  ///   - path: path used to store the setting
  ///   - value: setting value
  set(String path, dynamic value) async {
    try {
      var searchPaths = _getSearchPaths(path);
      // if (searchPaths.length == 1) {
      //   throw Exception("Missing scope 'user' or 'device' as the start of the path");
      // }
      await setSetting(searchPaths[0], value);
      _fire(searchPaths[0], value);
    } catch (error) {
      print(error);
    }
  }

  /// get setting for given path
  /// - Parameter path: path for the setting
  /// - Returns: setting value
  Future<T?> getSetting<T>(String path) async {
    var settingRowIDs = (await ItemRecord.fetchWithType("Setting")).map((setting) => setting.rowId);

    var db = AppController.shared.databaseController.databasePool;

    var query = " item IN (${settingRowIDs.join(", ")})";
    var settings = await db.itemPropertyRecordsCustomSelect(query);

    StringDb? setting = settings.firstWhere(
        (setting) => setting is StringDb && setting.name == "keystr" && setting.value == path,
        orElse: () => null);
    if (setting == null) return null;
    var settingRowID = setting.item;

    setting = settings.firstWhere(
        (setting) => setting is StringDb && setting.item == settingRowID && setting.name == "json",
        orElse: () => null);
    if (setting?.value != null) {
      return jsonDecode(setting!.value) as T?;
    } else {
      return null;
    }
  }

  /// Get setting as String for given path
  /// - Parameter path: path for the setting
  /// - Returns: setting value as String
  Future<String> getSettingString(String path) async {
    return await getSetting<String>(path) ?? "";
  }

  /// Sets a setting to the value passed.Also responsible for saving the setting to the permanent storage
  /// - Parameters:
  ///   - path: path of the setting
  ///   - value: setting Value
  setSetting(String path, dynamic value) async {
    var settingRowIDs = (await ItemRecord.fetchWithType("Setting")).map((setting) => setting.rowId);

    var db = AppController.shared.databaseController.databasePool;

    var query = " item IN (${settingRowIDs.join(", ")})";
    var settings = await db.itemPropertyRecordsCustomSelect(query);

    StringDb? setting = settings.firstWhere(
        (setting) => setting is StringDb && setting.name == "keystr" && setting.value == path,
        orElse: () => null);
    int? settingRowID = setting?.item;

    var settingItem = ItemRecord(
      type: "Setting",
      rowId: settingRowID,
    );

    if (settingRowID == null) {
      await settingItem.save();
      await settingItem.setPropertyValue("keystr", PropertyDatabaseValueString(path),
          state: SyncState.create);
    }

    await settingItem.setPropertyValue("json", PropertyDatabaseValueString(jsonEncode(value)),
        state: SyncState.create);
  }

  _fire(String path, dynamic value) {
    var list = _listeners[path];
    if (list != null) {
      for (var id in list) {
        var f = _callbacks[id];
        if (f != null) {
          f(value);
        }
      }
    }
  }

  addListener<T>(String path, Uuid id, void Function(dynamic) f) async {
    var normalizedPath = _getSearchPaths(path).asMap()[0];
    if (normalizedPath == null) {
      throw Exception("Invalid path");
    }

    if (_listeners[normalizedPath] == null) {
      _listeners[normalizedPath] = [];
    }
    if (!(_listeners[normalizedPath]?.contains(id) ?? false)) {
      _listeners[normalizedPath]?.add(id);
      _callbacks[id] = f;

      var value = await get<T>(path);
      if (value != null) {
        _fire(normalizedPath, value);
      }
    }
  }

  removeListener(String path, Uuid id) {
    _listeners[path]?.removeWhere((uid) => uid == id);
    _callbacks.remove(id);
  }
}
