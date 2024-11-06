import 'package:aptech_e_project_flutter/Auth/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';

const List<TabItem> items = [
  TabItem(
    icon: Icons.home,
    title: 'Home',
  ),
  TabItem(
    icon: Icons.search_sharp,
    title: 'Shop',
  ),
  TabItem(
    icon: Icons.favorite_border,
    title: 'Wishlist',
  ),
  TabItem(
    icon: Icons.shopping_cart_outlined,
    title: 'Cart',
  ),
  TabItem(
    icon: Icons.account_box,
    title: 'Profile',
  ),
];

/// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  int visit = 0; // Define `visit` as a class member

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser; // Get the currently logged-in user
  }

  void _checkUserStatus() {
    if (_user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()), // Navigate to WelcomePage
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = 30;
    String username = _user?.email?.split('@')[0] ?? "User";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: PopupMenuButton(
          icon: Icon(Iconsax.profile_circle, color: Colors.black45),
          onSelected: (value) {
            if (value == 'profile' && _user != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Hello, $username')),
              );
            } else if (value == 'profile') {
              _checkUserStatus();
            } else if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: _user != null ? Text("Hello, $username") : Text("Login"),
            ),
            if (_user != null) // Show Logout option only if user is logged in
              PopupMenuItem(
                value: 'logout',
                child: Text("Logout"),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 23.0),
            child: Row(
              children: [
                Icon(Iconsax.heart, color: Colors.black45),
                const SizedBox(width: 15.0),
                Icon(Iconsax.search_favorite, color: Colors.black45),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text("Hello, $username"),
            SizedBox(height: height),
            BottomBarDefault(
              items: items,
              backgroundColor: Colors.green,
              color: Colors.white,
              colorSelected: Colors.orange,
              indexSelected: visit,
              paddingVertical: 25,
              onTap: (int index) => setState(() {
                visit = index;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
