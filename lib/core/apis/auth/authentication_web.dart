import 'dart:math';
import 'dart:typed_data';

import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/apis/auth/auth_key.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class Authentication {
  static String rootKeyTag = "memriPrivateKey";
  static bool isOwnerAuthenticated = false;
  static String? lastRootPublicKey;

  static bool get storageDoesNotExist => false;

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

  static GeneratedKeys generateAllKeys([String? predefinedKey]) {
    var dbKey = generateCryptoStrongKey();
    //TODO: commenting this out until Pod not supporting asymmetric key encryption
    /*var rsapars = ECKeyGeneratorParameters(ECCurve_secp256k1());
    var params = ParametersWithRandom(rsapars, getSecureRandom());
    var keyGenerator = ECKeyGenerator();
    keyGenerator.init(params);
    var keyPair = keyGenerator.generateKeyPair();
    var privateKey = keyPair.privateKey as ECPrivateKey;
    var publicKey = keyPair.publicKey as ECPublicKey;
    var privateKeyStr = privateKey.d!.toRadixString(16);
    var publicKeyStr = publicKey.Q!.x!.toBigInteger()!.toRadixString(16);
    */
    AppLogger.info(dbKey);
    var publicKeyStr = predefinedKey ?? generateCryptoStrongKey();
    AppLogger.info(publicKeyStr);
    //TODO: return private key
    return GeneratedKeys(privateKey: "", publicKey: publicKeyStr, dbKey: dbKey);
  }

  static String generateCryptoStrongKey() {
    return "${Uuid().v4(options: {'rng': UuidUtil.cryptoRNG})}${Uuid().v4(options: {
          'rng': UuidUtil.cryptoRNG
        })}"
        .replaceAll("-", "");
  }

  static Future<GeneratedKeys> createOwnerAndDBKey([String? predefinedKey]) async {
    var keys = generateAllKeys(predefinedKey);
    await setOwnerAndDBKey(
        privateKey: keys.privateKey, publicKey: keys.publicKey, dbKey: keys.dbKey);
    return keys;
  }

  static void createRootKey() => isOwnerAuthenticated = true;

  static setOwnerAndDBKey(
      {required String privateKey, required String publicKey, required String dbKey}) async {
    await ItemRecord.setOwnerAndDBKey(privateKey: privateKey, publicKey: publicKey, dbKey: dbKey);
  }

  static Future<AuthKeys> getOwnerAndDBKey() async => await ItemRecord.getOwnerAndDBKey();
}
