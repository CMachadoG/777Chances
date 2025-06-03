import 'package:flutter/material.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  late GlobalKey<NavigatorState> navigatorKey;

  void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  void logout() {
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('login', (route) => false);
  }
}
