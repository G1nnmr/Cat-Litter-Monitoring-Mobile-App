import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _deviceCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _deviceCodeError;

  Future<void> _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final deviceCode = _deviceCodeController.text.trim();

    setState(() {
      _deviceCodeError = null; // Reset device code error on every submit
    });

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || deviceCode.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.195.250.63/signup.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'email': email,
          'password': password,
          'device_code': deviceCode,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      print('Signup response: $data');

      if (data['success'] == true) {
        _showMessage('Signup successful! You can now login.');

        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _deviceCodeController.clear();

        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final message = data['message'] ?? 'Signup failed';

        if (message.contains('machine code')) {
          setState(() {
            _deviceCodeError = message;
          });
        } else {
          _showMessage(message);
        }
      }
    } on TimeoutException {
      _showMessage('Server timed out. Please try again.');
    } on FormatException {
      _showMessage('Invalid server response. Please check backend.');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: mediaHeight * 0.08),
                      const Center(
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ComicNeue',
                            color: Color(0xFF5E412F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Create your account",
                          style: TextStyle(fontSize: 15, color: Colors.brown),
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration("Username", Icons.person),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration("Email", Icons.email),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecorationWithToggle(
                          "Password",
                          Icons.lock,
                          _obscurePassword,
                          () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecorationWithToggle(
                          "Confirm Password",
                          Icons.lock_outline,
                          _obscureConfirmPassword,
                          () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _deviceCodeController,
                        decoration: _inputDecoration("Machine Code", Icons.qr_code_2).copyWith(
                          errorText: _deviceCodeError,
                        ),
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFFC9D9A),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      const Center(child: Text("Or", style: TextStyle(color: Color(0xFF5E412F)))),
                      const SizedBox(height: 10),

                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF5E412F)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            _showMessage('Google Sign-In not implemented yet');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.android, color: Color(0xFF5E412F)),
                              SizedBox(width: 12),
                              Text(
                                "Sign In with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5E412F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Already have an account?", style: TextStyle(color: Color(0xFF5E412F))),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFFFC9D9A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      fillColor: const Color(0xFFFFE4B5),
      filled: true,
      prefixIcon: Icon(icon, color: const Color(0xFF5E412F)),
    );
  }

  InputDecoration _inputDecorationWithToggle(String hint, IconData icon, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      fillColor: const Color(0xFFFFE4B5),
      filled: true,
      prefixIcon: Icon(icon, color: const Color(0xFF5E412F)),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
        color: const Color(0xFF5E412F),
      ),
    );
  }
}
