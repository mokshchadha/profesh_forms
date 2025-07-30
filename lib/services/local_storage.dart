import 'package:profesh_forms/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<UserLocalInfo> getUserData() async {
    final token = await getData('token');
    final id = await getData('id');
    final type = await getData('userType');
    return UserLocalInfo(id: id, token: token, userType: type);
  }

  Future<void> storeUserData(String id, String token, String? userType) async {
    await setData('token', token);
    await setData('id', id);
    if (userType != null) await setData('userType', userType);
  }

  Future<String> getUserLanguage() async {
    final lang = await getData('language');
    if (lang == null) {
      return 'en';
    }
    return lang;
  }

  Future<void> setUserLanguage(String lang) async {
    await setData('language', lang);
  }

  Future<void> setData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('id');
    await prefs.remove('userType');
  }

  Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
