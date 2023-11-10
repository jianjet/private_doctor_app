import 'package:encrypt/encrypt.dart' as encrypt;

class AESEncryptionForPatientId {
  static final key = encrypt.Key.fromBase64('SndjV1o3ckNMYjUyNGE4UmpkSnVxTGp6djRyQnAwdlU=');
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  encryptMsg(String text) => encrypter.encrypt(text, iv: iv);

  decryptMsg(encrypt.Encrypted text) => encrypter.decrypt(text, iv: iv);

  getCode(String encoded) => encrypt.Encrypted.fromBase64(encoded);
}

class AESEncryptionForPatientHealthRecords {
  String symmetricKey;

  AESEncryptionForPatientHealthRecords(this.symmetricKey);

  static encrypt.Encrypter? encrypter;

  Future<void> initializeEncrypter() async {
    final key = encrypt.Key.fromBase64(symmetricKey);
    encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  encryptMsg(String text) {
    if (encrypter == null) {
      throw Exception("Encrypter not initialized. Call initializeEncrypter() first.");
    }
    return encrypter!.encrypt(text, iv: encrypt.IV.fromLength(16));
  }

  decryptMsg(encrypt.Encrypted text) {
    if (encrypter == null) {
      throw Exception("Encrypter not initialized. Call initializeEncrypter() first.");
    }
    return encrypter!.decrypt(text, iv: encrypt.IV.fromLength(16));
  }

  getCode(String encoded) {
    return encrypt.Encrypted.fromBase64(encoded);
  }
}
