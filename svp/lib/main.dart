import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode =
      FocusNode(); // FocusNode for password field
  bool _loading = false;
  Color _buttonColor = Color.fromRGBO(143, 148, 251, 1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_loading) {
      setState(() {
        _loading = true;
        _buttonColor = Colors.grey;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      if (email.isNotEmpty && password.isNotEmpty) {
        Map<String, dynamic> data = {
          'email': email,
          'password': password,
        };

        String jsonData = jsonEncode(data);

        try {
          http.Response response = await http.post(
            Uri.parse('https://svp.com.np/api'),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonData,
          );

          if (response.statusCode == 301 || response.statusCode == 302) {
            // Get redirected URL from headers
            String? redirectUrl = response.headers['location'];
            if (redirectUrl != null) {
              print('Redirected URL: $redirectUrl');
              // Make another request to the redirected URL
              response = await http.get(
                Uri.parse(redirectUrl),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                },
              );
            } else {
              print('Error: Redirect URL is null');
            }
          }

          if (response.statusCode == 200) {
            // ignore: unused_local_variable
            Map<String, dynamic> responseData = jsonDecode(response.body);
            print('Response body: ${response.body}');
            print('Login successful!');
            // Navigate to second page on successful login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondPage()),
            );
          } else {
            print('Error: ${response.statusCode}');
          }
        } catch (error) {
          print('Error: $error');
        }

        setState(() {
          _loading = false;
          _buttonColor = Color.fromRGBO(143, 148, 251, 1);
        });
      } else {
        print('Please enter email and password');
      }
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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 130,
                        top: 60,
                        child: Container(
                          width: 120,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/clock.png'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          margin: EdgeInsets.only(top: 120),
                          child: Center(
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
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                        boxShadow: [
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
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(),
                            ),
                            child: TextField(
                              controller: _emailController,
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                        boxShadow: [
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
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              _buttonColor,
                              Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: _loading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color.fromRGBO(143, 148, 251, 1),
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

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Center(
        child: Text("You are in the second page!"),
      ),
    );
  }
}
