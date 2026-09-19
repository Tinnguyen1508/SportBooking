import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_otp_screen.dart';
import 'screens/payment_screen.dart';

//import 'screens/review_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đặt sân thể thao',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/payment': (context) => const PaymentScreen(),
        //'/review': (context) => const ReviewScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp-verify') {
          return MaterialPageRoute(
            builder: (context) => const RegisterOtpScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
