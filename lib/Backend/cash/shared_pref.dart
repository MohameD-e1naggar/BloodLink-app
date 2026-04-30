import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:www/Backend/models/Request.dart';

import '../models/User.dart';

class SharedPref {
  static late SharedPreferences sharedPreferences;

  // Keys for storing data
  static const String _userKey = 'currentUser';
  static const String _reqsKey = 'userReqs';
  static const String _acceptedReqsKey = 'acceptedReqs';
  static const String _rejectedReqsKey = 'rejectedReqs';
  static const String _hiddenReqsKey = 'hiddenReqs';

  static Future<void> init() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      print('SharedPref.init() failed: $e');
      rethrow;
    }
  }

  static Future<bool> clear() async {
    try {
      await sharedPreferences.clear();
      return true;
    } catch (e) {
      print('SharedPref.clear() failed: $e');
      return false;
    }
  }


  static Future<bool> setUser(User? user) async {
    try {
      if (user == null) {
        // If user is null, remove the key
        await sharedPreferences.remove(_userKey);
        return true;
      }
      
      final jsonString = jsonEncode(user.toMap());
      final success = await sharedPreferences.setString(_userKey, jsonString);
      
      if (!success) {
        print('⚠️ SharedPref.setUser() returned false');
      }
      return success;
    } catch (e) {
      print('❌ SharedPref.setUser() failed: $e');
      return false;
    }
  }

  /// Safely saves a list of Requests to SharedPreferences
  /// Returns true if successful, false otherwise
  static Future<bool> setReqs(List<Request>? reqs) async {
    try {
      if (reqs == null || reqs.isEmpty) {
        // If list is null or empty, remove the key
        await sharedPreferences.remove(_reqsKey);
        return true;
      }

      final listMap = reqs.map((req) => req.toMap()).toList();
      final jsonString = jsonEncode(listMap);
      final success = await sharedPreferences.setString(_reqsKey, jsonString);
      
      if (!success) {
        print('SharedPref.setReqs() returned false');
      }
      return success;
    } catch (e) {
      print('SharedPref.setReqs() failed: $e');
      return false;
    }
  }

  /// Safely retrieves User from SharedPreferences
  /// Returns null if not found or on error
  static Future<User?> getUser() async {
    try {
      final jsonString = sharedPreferences.getString(_userKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromMap(map);
    } catch (e) {
      print('SharedPref.getUser() failed: $e');
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
          .whereType<Request>() // Filters out null values
          .toList();
    } catch (e) {
      print('SharedPref.getReqs() failed: $e');
      return [];
    }
  }

  /// Removes a specific key from SharedPreferences
  static Future<bool> removeKey(String key) async {
    try {
      final success = await sharedPreferences.remove(key);
      return success;
    } catch (e) {
      print('SharedPref.removeKey($key) failed: $e');
      return false;
    }
  }

  // --- Local Request States for Donor ---

  static Future<List<String>> _getStringList(String key) async {
    try {
      return sharedPreferences.getStringList(key) ?? [];
    } catch (e) {
      print('SharedPref._getStringList($key) failed: $e');
      return [];
    }
  }

  static Future<bool> _addToStringList(String key, String value) async {
    try {
      final list = await _getStringList(key);
      if (!list.contains(value)) {
        list.add(value);
        return await sharedPreferences.setStringList(key, list);
      }
      return true;
    } catch (e) {
      print('SharedPref._addToStringList($key) failed: $e');
      return false;
    }
  }

  static Future<List<String>> getAcceptedReqs() => _getStringList(_acceptedReqsKey);
  static Future<bool> addAcceptedReq(String id) => _addToStringList(_acceptedReqsKey, id);

  static Future<List<String>> getRejectedReqs() => _getStringList(_rejectedReqsKey);
  static Future<bool> addRejectedReq(String id) => _addToStringList(_rejectedReqsKey, id);

  static Future<List<String>> getHiddenReqs() => _getStringList(_hiddenReqsKey);
  static Future<bool> addHiddenReq(String id) => _addToStringList(_hiddenReqsKey, id);

}