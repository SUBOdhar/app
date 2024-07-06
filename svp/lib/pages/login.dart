import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mainurl = "https://api.svp.com.np";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _loading = false;
  Color _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _login();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AutofillGroup(
                child: Column(
                  children: <Widget>[
                    _buildTextField(
                        _emailController, "Email", Icons.mail, false),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _passwordController, "Password", Icons.lock, true),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      IconData icon, bool isPassword) {
    return Container(
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
            child: TextField(
              controller: controller,
              focusNode: isPassword ? _passwordFocusNode : null,
              obscureText: isPassword && _obscureText,
              autofillHints:
                  isPassword ? [AutofillHints.password] : [AutofillHints.email],
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(icon),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[700]),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: isPassword
                  ? null
                  : (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  void _login() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _buttonColor = Colors.grey;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      await _useStoredCredentials();
      if (email.isEmpty || password.isEmpty) {
        _showSnackBar('Please enter both email and password.');
        _resetLoadingState();
        return;
      }
    }

    final success = await _performLogin(email, password);
    if (success != null && success) {
      final String? key = await _getStoredKey();
      if (key != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(username: email)),
        );
      } else {
        _showSnackBar('Login failed. Please try again.');
      }
    } else {
      _showSnackBar('Login failed. Please try again.');
    }
    _resetLoadingState();
  }

  Future<void> _useStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedEmail = prefs.getString('email') ?? '';
    String storedPassword = prefs.getString('password') ?? '';
    int storedTimestamp = prefs.getInt('timestamp') ?? 0;

    if (storedEmail.isNotEmpty && storedPassword.isNotEmpty) {
      DateTime storedDateTime =
          DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
      DateTime now = DateTime.now();
      final difference = now.difference(storedDateTime).inDays;
      if (difference <= 13) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(username: storedEmail)),
        );
        setState(() {
          _loading = false;
          _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
        });
      } else {
        await _clearStoredCredentials();
      }
    }
  }

  Future<bool?> _performLogin(String email, String password) async {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'app': 'svp_admin',
    };

    String jsonData = jsonEncode(data);

    try {
      http.Response response = await http.post(
        Uri.parse('$mainurl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        final jsndata = jsonDecode(response.body);
        final String key = jsndata['key'];
        print('Response body: ${response.body}');
        print('Login successful!');
        await _saveCredentials(email, password, key);
        return true;
      } else if (response.statusCode == 401) {
        await _clearStoredCredentials();
        _showSnackBar('Invalid credentials. Please try again.');
        print('Error: 401 Unauthorized');
        return false;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      _showSnackBar('An error occurred. Please try again later.');
      return false;
    }
  }

  Future<void> _clearStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('timestamp');
    prefs.remove('key');
  }

  Future<void> _saveCredentials(
      String email, String password, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    prefs.setInt('timestamp', DateTime.now().millisecondsSinceEpoch);
    prefs.setString('key', key);
  }

  Future<String?> _getStoredKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('key');
  }

  void _resetLoadingState() {
    setState(() {
      _loading = false;
      _buttonColor = const Color.fromRGBO(143, 148, 251, 1);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
