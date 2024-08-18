// import 'dart:convert';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class SecuredSharedPrefUtils {
//   static const consPref = "CONS_PREF";
//
//   static const spOrderId = "spOrderId";
//   static const spItemId = "spItemId";
//
//   static final SecuredSharedPrefUtils _instance = SecuredSharedPrefUtils._ctor();
//
//   factory SecuredSharedPrefUtils() {
//     return _instance;
//   }
//
//   SecuredSharedPrefUtils._ctor();
//
//   static late FlutterSecureStorage _prefs;
//   static AndroidOptions _secureOption() => const AndroidOptions(
//     encryptedSharedPreferences: true,
//   );
//
//   static securedInit() {
//     _prefs = const FlutterSecureStorage();
//   }
//
//   static setConsStringValue(String key, String value) async {
//     bool hasConsPref =  await _prefs.containsKey(key: consPref, aOptions: _secureOption());
//     final String? storedData =   hasConsPref ? await _prefs.read(key: consPref,aOptions: _secureOption()) : null;
//     Map newData = {key: value};
//     Map newDataMap = {};
//
//     if (storedData != null) {
//       newDataMap.addAll(jsonDecode(storedData));
//       newDataMap.addAll(newData);
//     } else {
//       newDataMap = newData;
//     }
//
//     await _prefs.write(key:consPref, value: jsonEncode(newDataMap), aOptions: _secureOption());
//   }
//
//   static Future<String> getConsStringValue(String key) async {
//     Map<String, dynamic> allPrefs = await _prefs.read(key: consPref,aOptions: _secureOption()) != null
//         ? jsonDecode(await _prefs.read(key:consPref,aOptions: _secureOption()) ?? '')
//         : {};
//
//     return allPrefs[key] ?? "";
//   }
//
//   static set setSportsPoolLastOrderId(String value)    => setConsStringValue(spOrderId, value);
//   static set setSportsPoolLastItemId(String value)    => setConsStringValue(spItemId, value);
//
//   static Future<String> get getSportsPoolLastOrderId   => getConsStringValue(spOrderId);
//   static Future<String> get getSportsPoolLastItemId   => getConsStringValue(spItemId);
//
//   static void removeValue(String value) async {
//     await _prefs.deleteAll(aOptions: _secureOption());
//   }
//
// }

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecuredSharedPrefUtils {
  static const spOrderId = "spOrderId";
  static const spItemId = "spItemId";

  static final SecuredSharedPrefUtils _instance = SecuredSharedPrefUtils._ctor();

  factory SecuredSharedPrefUtils() {
    return _instance;
  }

  SecuredSharedPrefUtils._ctor();

  static late FlutterSecureStorage _prefs;
  static AndroidOptions _secureOption() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static securedInit() {
    _prefs = const FlutterSecureStorage();
  }

  static setConsStringValue(String key, String value) async {
    await _prefs.write(key:key, value: value, aOptions: _secureOption());
  }

  static Future<String> getConsStringValue(String key) async {
    return await _prefs.read(key: key,aOptions: _secureOption()) ?? "";
  }

  static set setSportsPoolLastOrderId(String value)    => setConsStringValue(spOrderId, value);
  static set setSportsPoolLastItemId(String value)    => setConsStringValue(spItemId, value);

  static Future<String> get getSportsPoolLastOrderId   => getConsStringValue(spOrderId);
  static Future<String> get getSportsPoolLastItemId   => getConsStringValue(spItemId);

  static void removeValue(String value) async {
    await _prefs.deleteAll(aOptions: _secureOption());
  }

}