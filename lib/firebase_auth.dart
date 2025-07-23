// auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:new_revenue/dashboard_screen.dart'; // Import DashboardScreen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          // If user is logged in, check if they are anonymous.
          // If anonymous, force them to AuthScreen to sign up/in.
          // Otherwise, navigate to DashboardScreen.
          if (user.isAnonymous) {
            return const AuthScreen(); // Show login/signup for anonymous users
          } else {
            return const DashboardScreen(); // User is a non-anonymous, authenticated user
          }
        } else {
          // User is not logged in at all, show AuthScreen
          return const AuthScreen();
        }
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLogin = true; // To toggle between login and signup
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.05)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw FirebaseAuthException(
            code: 'password-mismatch',
            message: 'Passwords do not match.',
          );
        }
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Error',
            style: TextStyle(color: Colors.redAccent)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child:
                const Text('Okay', style: TextStyle(color: Colors.deepPurple)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // New method to handle the animation sequence
  Future<void> _playButtonAnimation() async {
    await _animationController.forward();
    await _animationController.reverse();
  }

  // Corrected: Changed onPressedCallback type to Future<void> Function()
  Widget _buildAuthButton(
      String text, Future<void> Function() onPressedCallback) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  HapticFeedback.lightImpact(); // Haptic feedback on tap
                  await _playButtonAnimation(); // Call the dedicated animation method

                  await onPressedCallback(); // Execute the button's primary action
                  if (_errorMessage != null) {
                    _showErrorDialog(_errorMessage!);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: Colors.deepPurple.shade200,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Placeholder for a logo. Ensure you have 'assets/logo.png'
              // in your project, or remove this Hero widget.
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/logo.png', // Add a logo.png in your assets folder
                  height: 120,
                  width: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 120,
                      color: Colors.deepPurple,
                    ); // Fallback icon
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Revenue2',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.deepPurple),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),
                      if (!_isLogin) const SizedBox(height: 20),
                      if (!_isLogin)
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.deepPurple),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.deepPurple, width: 2),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      _buildAuthButton(
                          _isLogin ? 'Login' : 'Sign Up', _authenticate),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null; // Clear error when toggling
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Create an account'
                              : 'I already have an account',
                          style: TextStyle(
                              color: Colors.deepPurple.shade700, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
