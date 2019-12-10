import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesClient {
  PreferencesClient({this.prefs});

  final SharedPreferences prefs;

  String getUserName() {
    final String username = prefs.getString('username');
    if (username == null) {
      return null;
    }
    return username;
  }

  void saveUserName(String username) {
    prefs.setString('username', username);
    print('Saved username in shared preference $username');
  }
}
