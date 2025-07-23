import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for Firebase.initializeApp
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for signOut
import 'package:new_revenue/firebase_auth.dart'; // Import AuthWrapper

void main() async {
  // Ensure Flutter widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services once at the start of the app
  try {
    await Firebase.initializeApp();
    // Force sign out any existing user (anonymous or otherwise)
    // This ensures AuthWrapper starts with a clean slate and shows AuthScreen.
    await FirebaseAuth.instance.signOut();
    print(
        'Signed out any existing user at app startup to ensure login page is shown.');

    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors, e.g., show an error screen
    print('Failed to initialize Firebase or sign out: $e');
    runApp(ErrorApp(errorMessage: 'Failed to initialize Firebase: $e'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Revenue',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Using deepPurple as primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.amber), // Accent color
        fontFamily: 'Roboto', // Example font family
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        // Add more theme customizations as desired
      ),
      home: const AuthWrapper(), // Set AuthWrapper as the initial home screen
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}

// Simple error widget for initialization failures
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'An error occurred during app startup: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
