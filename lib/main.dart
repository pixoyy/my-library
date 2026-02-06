import 'package:flutter/material.dart';
import 'package:my_library/features/auth/login_page.dart';
import 'package:my_library/features/auth/register_page.dart';
import 'package:my_library/layout/main_layout.dart';
import 'core/theme/app_theme.dart';
// import 'core/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Autumn Library',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/main': (_) => const MainLayout(),
      },
    );
  }
}
