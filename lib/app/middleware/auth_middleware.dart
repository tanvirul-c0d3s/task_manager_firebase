import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;

    // Not logged in → block everything except login/register
    if (user == null &&
        route != Routes.login &&
        route != Routes.register) {
      return const RouteSettings(name: Routes.login);
    }

    // Logged in → block login/register
    if (user != null &&
        (route == Routes.login || route == Routes.register)) {
      return const RouteSettings(name: Routes.home);
    }

    return null;
  }
}
