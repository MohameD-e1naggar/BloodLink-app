import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:www/core/models/blood_request.dart';

import 'package:www/core/models/user.dart';

class SharedPreferencesHelper {
  static late SharedPreferences sharedPreferences;

  static const String _userKey = 'currentUser';
  static const String _reqsKey = 'userReqs';
  static const String _themeKey = 'isDarkMode';


  static Future<void> init() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      print('SharedPreferencesHelper.init() failed: $e');
      rethrow;
    }
  }

  static Future<bool> clear() async {
    try {
      await sharedPreferences.clear();
      return true;
    } catch (e) {
      print('SharedPreferencesHelper.clear() failed: $e');
      return false;
    }
  }

  static Future<bool> setUser(User user) async {
    try {
      final jsonString = jsonEncode(user.toMap());
      final success = await sharedPreferences.setString(_userKey, jsonString);
      if (!success) {
        print('SharedPreferencesHelper.setUser() returned false');
      }
      return success;
    } catch (e) {
      print('SharedPreferencesHelper.setUser() failed: $e');
      return false;
    }
  }

  static Future<bool> setReqs(List<Request>? reqs) async {
    try {
      if (reqs == null || reqs.isEmpty) {
        await sharedPreferences.remove(_reqsKey);
        return true;
      }

      final listMap = reqs.map((req) => req.toMap()).toList();
      final jsonString = jsonEncode(listMap);
      final success = await sharedPreferences.setString(_reqsKey, jsonString);

      if (!success) {
        print('SharedPreferencesHelper.setReqs() returned false');
      }
      return success;
    } catch (e) {
      print('SharedPreferencesHelper.setReqs() failed: $e');
      return false;
    }
  }

  static Future<User?> getUser() async {
    try {
      final jsonString = sharedPreferences.getString(_userKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromMap(map);
    } catch (e) {
      print('SharedPreferencesHelper.getUser() failed: $e');
      return null;
    }
  }

  static Future<List<Request>> getReqs() async {
    try {
      final jsonString = sharedPreferences.getString(_reqsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((item) {
            try {
              return Request.fromMap(item as Map<String, dynamic>);
            } catch (e) {
              print('Failed to parse Request item: $e');
              return null;
            }
          })
          .whereType<Request>()
          .toList();
    } catch (e) {
      print('SharedPreferencesHelper.getReqs() failed: $e');
      return [];
    }
  }

  static Future<bool> removeKey(String key) async {
    try {
      final success = await sharedPreferences.remove(key);
      return success;
    } catch (e) {
      print('SharedPreferencesHelper.removeKey($key) failed: $e');
      return false;
    }
  }

  static Future<void> setThemeMode(bool isDark) async {
    try {
      await sharedPreferences.setBool(_themeKey, isDark);
    } catch (e) {
      print('SharedPreferencesHelper.setThemeMode() failed: $e');
    }
  }

  static bool getThemeMode() {
    try {
      return sharedPreferences.getBool(_themeKey) ?? true;
    } catch (e) {
      print('SharedPreferencesHelper.getThemeMode() failed: $e');
      return true;
    }
  }

}