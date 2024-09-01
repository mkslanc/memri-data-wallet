import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Authentication {
  static bool isOwnerAuthenticated = false;
  FlutterSecureStorage storage = FlutterSecureStorage();

  factory Authentication() {
    return _singleton;
  }

  Authentication._internal();

  static Authentication get instance => Authentication();

  static final Authentication _singleton = Authentication._internal();

  Future<String?> getOwnerKey() async {
    return storage.read(key: "ownerKey");
  }

  Future<String?> getDbKey() async {
    return storage.read(key: "dbKey");
  }

  setDbKey(String dbKey) async {
    await storage.write(key: "dbKey", value: dbKey);
  }

  setOwnerKey(String ownerKey) async {
    await storage.write(key: "ownerKey", value: ownerKey);
  }

  removeAll() async {
    await storage.deleteAll();
  }

  Future<bool> hasPodKeys() async {
    var dbKey = await getDbKey();
    var ownerKey = await getDbKey();
    return dbKey != null && ownerKey != null;
  }

}
