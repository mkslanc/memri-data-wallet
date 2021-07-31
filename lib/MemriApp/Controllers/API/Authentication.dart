import 'dart:math';
import 'dart:typed_data';

import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:biometric_storage/biometric_storage.dart';

class Authentication {
  static String rootKeyTag = "memriPrivateKey";
  static bool isOwnerAuthenticated = false;
  static BiometricStorageFile? storage;

  static Future<bool> get hasSecureEnclave async {
    return hasBiometrics;
  }

  /// Check that this device has Biometrics features available
  static Future<bool> get hasBiometrics async {
    var canAuthenticate = await BiometricStorage().canAuthenticate();
    if (canAuthenticate == CanAuthenticateResponse.success) {
      return true;
    }
    return false;
  }

  static authenticateOwner() async {
    if (await hasBiometrics) {
      if (await storageIsNotExists) {
        throw Exception("Couldn't read value from storage");
      }
      isOwnerAuthenticated = true;
    } else {
      //TODO: when https://github.com/authpass/biometric_storage/pull/28 PR will be accepted, we could implement authentication without biometric
      throw Exception("Couldn't authenticate user without biometric");
    }
  }

  static Future<bool> get storageIsNotExists async {
    try {
      if (storage == null) storage = await BiometricStorage().getStorage(rootKeyTag);
      var result = await storage!.read();
      if (result == null) {
        return true;
      }
      return false;
    } on Exception catch (e) {
      if (e is AuthException) {
        switch (e.code) {
          case AuthExceptionCode.userCanceled:
            throw Exception("Authorisation was cancelled");
          case AuthExceptionCode.unknown:
            if (e.message == "Cancel") {
              throw Exception("Authorisation was cancelled");
            }
            throw Exception(e.message);
          case AuthExceptionCode.timeout:
            throw Exception("Exceeded authorisation timeout");
          default:
            throw Exception(e.message);
        }
      } else {
        throw Exception("Unknown error");
      }
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
    if (storage == null) storage = await BiometricStorage().getStorage(rootKeyTag);
    await storage!.write(""); //TODO: place for your key
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
