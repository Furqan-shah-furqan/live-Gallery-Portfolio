import 'package:shared_preferences/shared_preferences.dart';

Future<String?> readProjectJson(String key) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getString(key);
}

Future<void> writeProjectJson(String key, String value) async {
  final preferences = await SharedPreferences.getInstance();
  final saved = await preferences.setString(key, value);
  if (!saved) {
    throw StateError('The project data could not be written to local storage.');
  }
}
