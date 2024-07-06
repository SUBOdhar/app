import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svp/pages/check.dart';
import 'package:svp/pages/dealer.dart';
import 'package:svp/pages/add_product.dart';
import 'package:svp/pages/clear.dart';
import 'package:svp/pages/login.dart' as mail_app;
import 'package:svp/pages/report.dart';
import 'package:svp/pages/sell.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:svp/pages/version/version.dart';
import 'package:svp/pages/chicken.dart';

class Home extends StatefulWidget {
  final String username;
  const Home({required this.username, super.key});

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Home> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final VersionService _versionService = VersionService();
  String _serverVersion = '';
  Uri? _updateurl;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkVersion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkVersion() async {
    try {
      final result = await _versionService.checkVersion();
      print('API response: $result'); // Debugging statement

      setState(() {
        if (result['status'] == 'update_needed') {
          _serverVersion = result['global_version'] ?? '';
          String urlString = result['url'] ?? '';
          print('Parsed URL String: $urlString'); // Debugging statement

          if (urlString.isNotEmpty) {
            _updateurl = Uri.tryParse(urlString);
            if (_updateurl == null) {
              print('Invalid URL: $urlString'); // Debugging statement
            } else {
              print('Parsed Uri: $_updateurl'); // Debugging statement
            }
          } else {
            _updateurl = null;
          }

          _showUpdateDialog();
        } else {
          _serverVersion = '';
        }
      });
    } catch (e) {
      setState(() {
        print('Error checking version: $e'); // Debugging statement
      });
    }
  }

  void _showUpdateDialog() {
    if (_updateurl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update URL is empty')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: Text(
            'A new version ($_serverVersion) is available. Please update to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _launchURL();
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL() async {
    if (_updateurl != null) {
      if (await canLaunchUrl(_updateurl!)) {
        await launchUrl(_updateurl!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $_updateurl')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update URL is empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Welcome',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/clock.png'),
              ),
              accountName: Text(
                widget.username,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              accountEmail: Text(
                widget.username,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () {}),
            _buildDrawerItem(Icons.info, 'About', () {
              // Add your navigation logic here
            }),
            _buildDrawerItem(Icons.logout, 'Logout', () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('email');
              prefs.remove('password');
              prefs.remove('timestamp');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const mail_app.Login()),
              );
            }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: _buildButtonRow(
                  context,
                  [
                    _buildButtonData(
                        'Sell', FontAwesomeIcons.cartShopping, Colors.blue, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Sell()),
                      );
                    }),
                    _buildButtonData(
                        'Clear data', FontAwesomeIcons.broom, Colors.green, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Clear()),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _buildButtonRow(
                  context,
                  [
                    _buildButtonData(
                        'Add Product', FontAwesomeIcons.plus, Colors.orange,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Add()),
                      );
                    }),
                    _buildButtonData(
                        'Add Dealer', FontAwesomeIcons.userPlus, Colors.purple,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Dealer()),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _buildButtonRow(
                  context,
                  [
                    _buildButtonData('Check Stock',
                        FontAwesomeIcons.windowMaximize, Colors.teal, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Check()),
                      );
                    }),
                    _buildButtonData(
                        'Report', FontAwesomeIcons.fileLines, Colors.red, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Report()),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: _buildButtonRow(
                  context,
                  [
                    _buildButtonData('Chicken', FontAwesomeIcons.dove,
                        Colors.yellow.shade800, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Chicken()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildButtonRow(BuildContext context, List<ButtonData> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons
          .map((button) => _buildButton(
                context,
                button.text,
                button.icon,
                button.color,
                button.onPressed,
              ))
          .toList(),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 150, // Fixed width
      height: 60, // Fixed height
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: FaIcon(icon, size: 24),
        label: Text(text),
      ),
    );
  }

  ButtonData _buildButtonData(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ButtonData(
        text: text, icon: icon, color: color, onPressed: onPressed);
  }
}

class ButtonData {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  ButtonData({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
