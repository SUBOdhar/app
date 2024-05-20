import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/clock.png'),
            ),
            SizedBox(width: 10),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // Customize the leading property to use a different icon
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 30,
          ), // You can replace this with any icon you want
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Add your navigation logic here
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Add your navigation logic here
              },
            ),
            // Add more ListTiles for additional menu items
          ],
        ),
      ),
      body: const Center(
        child: Text('This is the page'),
      ),
    );
  }
}
