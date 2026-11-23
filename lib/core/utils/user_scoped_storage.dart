import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScopedStorage {
  static String get _userKey {
    final user = FirebaseAuth.instance.currentUser;
    final rawId = user?.uid ?? user?.email ?? 'guest';
    return rawId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  static String watchlistKey() => 'watchlist_$_userKey';
  static String historyKey() => 'history_$_userKey';

  static Future<void> saveStringList(String baseKey, List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = '${baseKey}_$_userKey';
    await prefs.setStringList(scopedKey, items);
  }

  static Future<List<String>> loadStringList(String baseKey) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = '${baseKey}_$_userKey';
    return prefs.getStringList(scopedKey) ?? <String>[];
  }

  static Future<void> clearCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(watchlistKey());
    await prefs.remove(historyKey());
  }
}