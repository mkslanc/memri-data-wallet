import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:local_auth/local_auth.dart';

class Authentication {
  static String rootKeyTag = "memriPrivateKey";
  static bool isOwnerAuthenticated = false;
  static FlutterSecureStorage storage = FlutterSecureStorage();
  static LocalAuthentication localAuth = LocalAuthentication();
  static String? lastRootPublicKey;

  static Future<bool> get hasSecureEnclave async {
    return hasBiometrics;
  }

  /// Check that this device has Biometrics features available
  static Future<bool> get hasBiometrics async {
    return await localAuth.canCheckBiometrics;
  }

  static authenticateOwner() async {
    if (await storageDoesNotExist) {
      throw Exception("Couldn't read value from storage");
    }
    isOwnerAuthenticated = true;
  }

  static Future<bool> get storageDoesNotExist async {
    try {
      if (await hasBiometrics) {
        bool didAuthenticate = await localAuth.authenticate(localizedReason: ' ');
        if (didAuthenticate) {
          var result = await storage.read(key: rootKeyTag);
          if (result == null) {
            return true;
          }
          lastRootPublicKey = result;
          isOwnerAuthenticated = true;
          return false;
        } else {
          throw Exception("User cancelled authentication");
        }
      }
      throw Exception("Couldn't authenticate user");
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  static SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  static GeneratedKeys generateAllKeys() {
    var dbKey = "${Uuid().v4()}${Uuid().v4()}".replaceAll("-", "").toUpperCase();
    var rsapars = ECKeyGeneratorParameters(ECCurve_secp256k1());
    var params = ParametersWithRandom(rsapars, getSecureRandom());
    var keyGenerator = ECKeyGenerator();
    keyGenerator.init(params);
    var keyPair = keyGenerator.generateKeyPair();
    var privateKey = keyPair.privateKey as ECPrivateKey;
    var publicKey = keyPair.publicKey as ECPublicKey;
    var privateKeyStr = privateKey.d!.toRadixString(16).toUpperCase();
    var publicKeyStr = publicKey.Q!.x!.toBigInteger()!.toRadixString(16).toUpperCase();
    return GeneratedKeys(privateKey: privateKeyStr, publicKey: publicKeyStr, dbKey: dbKey);
  }

  static Future<GeneratedKeys> createOwnerAndDBKey() async {
    var keys = generateAllKeys();
    await setOwnerAndDBKey(
        privateKey: keys.privateKey, publicKey: keys.publicKey, dbKey: keys.dbKey);
    return keys;
  }

  static Future<void> createRootKey() async {
    var localDbKey = "${Uuid().v4()}${Uuid().v4()}".replaceAll("-", "").toUpperCase();
    await storage.write(key: rootKeyTag, value: localDbKey);
    lastRootPublicKey = localDbKey;
    isOwnerAuthenticated = true;
  }

  static setOwnerAndDBKey(
      {required String privateKey, required String publicKey, required String dbKey}) async {
    await ItemRecord.setOwnerAndDBKey(privateKey: privateKey, publicKey: publicKey, dbKey: dbKey);
  }

  static Future<AuthKeys> getOwnerAndDBKey() async {
    return await ItemRecord.getOwnerAndDBKey();
  }
}

class AuthKey {
  int ownerId;
  String type;
  String? role;
  String key;
  String name;
  bool active;

  AuthKey(
      {required this.ownerId,
      required this.type,
      this.role,
      required this.key,
      required this.name,
      required this.active});

  Future<ItemRecord?> save(Database db) async {
    var item = ItemRecord(type: "CryptoKey");
    await item.save();
    var itemRowId = item.rowId;
    if (itemRowId == null) {
      throw Exception("Error saving key");
    }

    await ItemPropertyRecord(
            itemRowID: itemRowId, name: "itemType", value: PropertyDatabaseValueString(type))
        .save(db);
    if (role != null) {
      await ItemPropertyRecord(
              itemRowID: itemRowId, name: "role", value: PropertyDatabaseValueString(role!))
          .save(db);
    }
    await ItemPropertyRecord(
            itemRowID: itemRowId, name: "keystr", value: PropertyDatabaseValueString(key))
        .save(db); // "keystr" because "key" is restricted in pod db
    await ItemPropertyRecord(
            itemRowID: itemRowId, name: "name", value: PropertyDatabaseValueString(name))
        .save(db);
    await ItemPropertyRecord(
            itemRowID: itemRowId, name: "active", value: PropertyDatabaseValueBool(active))
        .save(db);

    return item;
  }
}

class AuthKeys {
  String ownerKey;
  String dbKey;

  AuthKeys({required this.ownerKey, required this.dbKey});
}

class GeneratedKeys {
  String publicKey;
  String privateKey;
  String dbKey;

  GeneratedKeys({required this.publicKey, required this.privateKey, required this.dbKey});
}
