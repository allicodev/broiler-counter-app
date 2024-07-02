import 'package:shared_preferences/shared_preferences.dart';

setKeyValue(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(key) ?? "";
  return token;
}
