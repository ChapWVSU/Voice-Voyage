import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voice_voyage/store.dart';
// Nov. 26, 2025 - added firebase import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'login.dart';
// import 'signup.dart';
import 'signup_test.dart';
import 'app_colors.dart';
import 'homepage.dart';
import 'settings.dart';
import 'dictionary.dart';
// ↓↓↓↓ PREV VOID MAIN ↓↓↓↓
// void main() => runApp(const MyApp());

// Nov. 26, 2025 - added firebase init
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Voyage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        primaryColor: AppColors.blueBoost,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueBoost,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/homepage': (context) => const HomePage(),
        '/store': (context) => const StorePage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
