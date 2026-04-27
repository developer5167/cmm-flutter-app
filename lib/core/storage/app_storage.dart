import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class AppStorage {
  AppStorage._();

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Secure Storage (Tokens) ──────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secure.write(key: StorageKeys.accessToken, value: accessToken),
      _secure.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _secure.read(key: StorageKeys.accessToken);

  static Future<String?> getRefreshToken() =>
      _secure.read(key: StorageKeys.refreshToken);

  static Future<void> saveUserId(String userId) =>
      _secure.write(key: StorageKeys.userId, value: userId);

  static Future<String?> getUserId() =>
      _secure.read(key: StorageKeys.userId);

  static Future<void> clearAll() => _secure.deleteAll();

  // ─── Hive Boxes ───────────────────────────────────────────────
  static late Box _prefs;

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await Hive.openBox('prefs');
  }

  static void saveOnboardingStep(int step) =>
      _prefs.put(StorageKeys.onboardingStep, step);

  static int getOnboardingStep() =>
      _prefs.get(StorageKeys.onboardingStep, defaultValue: 0) as int;

  static void saveOnboardingComplete(bool val) =>
      _prefs.put(StorageKeys.onboardingComplete, val);

  static bool isOnboardingComplete() =>
      _prefs.get(StorageKeys.onboardingComplete, defaultValue: false) as bool;
}
