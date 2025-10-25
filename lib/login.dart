import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();

  bool _isLoading = false;
  String _message = '';
  bool _obscurePassword = true; // 👈 add this

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final deviceCode = deviceCodeController.text.trim();

    if (username.isEmpty || password.isEmpty || deviceCode.isEmpty) {
      setState(() {
        _message = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final url = Uri.parse('http://10.195.250.63/login.php');
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'device_code': deviceCode,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = data['user'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: user['username'],
                email: user['email'],
              ),
            ),
          );
        } else {
          setState(() {
            _message = data['message'] ?? 'Login failed';
          });
        }
      } else {
        setState(() {
          _message = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/paw_bg.png"),
              fit: BoxFit.cover,
              opacity: 0.04,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/cat_welcome.json',
                    height: 120,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome Back, Meow!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ComicNeue',
                      color: Color(0xFF5E412F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Stay updated on your cat’s litter levels 🐾",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5E412F),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _textInput(usernameController, "Username", Icons.person),
                  const SizedBox(height: 14),
                  _passwordInput(), // 👈 replace with this custom password input
                  const SizedBox(height: 14),
                  _textInput(deviceCodeController, "Device Code", Icons.qr_code_2),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFC9D9A),
                        elevation: 5,
                        shadowColor: const Color(0xFF5E412F),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CircularProgressIndicator(),
                    ),

                  const SizedBox(height: 24),
                  const Divider(
                    thickness: 1,
                    color: Color(0xFFE0C097),
                    indent: 50,
                    endIndent: 50,
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot password, Meow?",
                      style: TextStyle(
                        color: Color(0xFF5E412F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF5E412F)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFFFC9D9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Lottie.asset(
                    'assets/animations/pawprints.json',
                    height: 60,
                    repeat: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textInput(TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF5E412F)),
        fillColor: const Color(0xFFFFE4B5),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordInput() {
    return TextField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF5E412F)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF5E412F),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        fillColor: const Color(0xFFFFE4B5),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
