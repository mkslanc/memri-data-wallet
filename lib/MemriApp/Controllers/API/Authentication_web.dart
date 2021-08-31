import 'dart:math';
import 'dart:typed_data';

import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:local_auth/local_auth.dart';

import 'AuthKey.dart';

class Authentication {
  static String rootKeyTag = "memriPrivateKey";
  static bool isOwnerAuthenticated = false;

  //static FlutterSecureStorage storage = FlutterSecureStorage();
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
    return false;
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
    var dbKey = "${Uuid().v4()}${Uuid().v4()}".replaceAll("-", "");
    var rsapars = ECKeyGeneratorParameters(ECCurve_secp256k1());
    var params = ParametersWithRandom(rsapars, getSecureRandom());
    var keyGenerator = ECKeyGenerator();
    keyGenerator.init(params);
    var keyPair = keyGenerator.generateKeyPair();
    var privateKey = keyPair.privateKey as ECPrivateKey;
    var publicKey = keyPair.publicKey as ECPublicKey;
    var privateKeyStr = privateKey.d!.toRadixString(16);
    var publicKeyStr = publicKey.Q!.x!.toBigInteger()!.toRadixString(16);
    print(publicKeyStr);
    print(dbKey);
    return GeneratedKeys(privateKey: privateKeyStr, publicKey: publicKeyStr, dbKey: dbKey);
  }

  static Future<GeneratedKeys> createOwnerAndDBKey() async {
    var keys = generateAllKeys();
    await setOwnerAndDBKey(
        privateKey: keys.privateKey, publicKey: keys.publicKey, dbKey: keys.dbKey);
    return keys;
  }

  static Future<void> createRootKey() async {
    isOwnerAuthenticated = true;
  }

  static Future<void> deleteRootKey() async {
    return;
  }

  static setOwnerAndDBKey(
      {required String privateKey, required String publicKey, required String dbKey}) async {
    await ItemRecord.setOwnerAndDBKey(privateKey: privateKey, publicKey: publicKey, dbKey: dbKey);
  }

  static Future<AuthKeys> getOwnerAndDBKey() async {
    return await ItemRecord.getOwnerAndDBKey();
  }
}
