import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'second_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _loading = false;
  Color _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loading) {
      setState(() {
        _loading = true;
        _buttonColor = Colors.grey;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        // Check if stored credentials exist
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String storedEmail = prefs.getString('email') ?? '';
        String storedPassword = prefs.getString('password') ?? '';
        int storedTimestamp = prefs.getInt('timestamp') ?? 0;

        if (storedEmail.isNotEmpty && storedPassword.isNotEmpty) {
          // Check if stored credentials are expired
          DateTime storedDateTime =
              DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
          DateTime now = DateTime.now();
          final difference = now.difference(storedDateTime).inDays;
          if (difference <= 13) {
            // Use stored credentials if not expired
            email = storedEmail;
            password = storedPassword;
          } else {
            // Remove expired credentials
            await prefs.remove('email');
            await prefs.remove('password');
            await prefs.remove('timestamp');
          }
        } else {
          // If no stored credentials, show error message
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enter email and password.'),
            backgroundColor: Colors.red,
          ));
          setState(() {
            _loading = false;
            _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
          });
          return;
        }
      }

      Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'app':'svp',
      };

      String jsonData = jsonEncode(data);

      try {
        http.Response response = await http.post(
          Uri.parse('https://api.svp.com.np/login'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        if (response.statusCode == 200) {
          // Login successful
          Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Response body: $responseData');
          print('Login successful!');

          // Save email, password, and timestamp
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', email);
          prefs.setString('password', password);
          prefs.setInt('timestamp', DateTime.now().millisecondsSinceEpoch);

          // Navigate to the SecondPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondPage()),
          );
        } else {
          // Login failed
          print('Error: ${response.statusCode}');
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (error) {
        // Error occurred during login request
        print('Error: $error');
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      }

      setState(() {
        _loading = false;
        _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 120,
                          height: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/clock.png'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          margin: const EdgeInsets.only(top: 170),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromRGBO(143, 148, 251, 1),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border(),
                            ),
                            child: TextField(
                              controller: _emailController,
                              autofillHints: [AutofillHints.email],
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.mail),
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromRGBO(143, 148, 251, 1),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              border: Border(),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              autofillHints: [AutofillHints.password],
                              obscureText: _obscureText,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              _buttonColor,
                              const Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
