import 'package:flutter/material.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../layout/main_layout.dart';

class AppRoutes {
  static const login = '/';
  static const register = '/register';
  static const main = '/main';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    main: (_) => const MainLayout(),
  };
}
