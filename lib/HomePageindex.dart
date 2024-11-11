import 'dart:async'; // Import for Timer
import 'package:aptech_e_project_flutter/Auth/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/rendering.dart'; // For ScrollDirection

const List<TabItem> items = [
  TabItem(icon: Icons.home, title: 'Home'),
  TabItem(icon: Icons.menu_book, title: 'Shop'),
  TabItem(icon: Icons.favorite_border, title: 'Wishlist'),
  TabItem(icon: Icons.shopping_cart_outlined, title: 'Cart'),
  TabItem(icon: Icons.account_box, title: 'Profile'),
];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  int visit = 0;
  bool _showBottomBar = true;
  final ScrollController _scrollController = ScrollController();

  // Create a PageController for automatic sliding
  final PageController _pageController = PageController();

  int _currentIndex = 0; // To keep track of the selected tab

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _scrollController.addListener(_scrollListener);

    // Start automatic sliding using Timer
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= 2) nextPage = 0; // Restart from the first page
        _pageController.animateToPage(
          nextPage,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showBottomBar) setState(() => _showBottomBar = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showBottomBar) setState(() => _showBottomBar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    String username = _user?.email?.split('@')[0] ?? "User";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800], // Softer dark gray for the AppBar
        elevation: 5,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(), // Open drawer using the context of Builder
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: PopupMenuButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.account_circle, color: Colors.black),
              ),
              onSelected: (value) {
                if (value == 'logout') _logout();
                if (value == 'profile') _checkUserStatus();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'profile', child: Text(_user != null ? "Hello, $username" : "Login", style: TextStyle(color: Colors.black38))),
                if (_user != null) PopupMenuItem(value: 'logout', child: Text("Logout", style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text("Wekcome To Book Store App", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text("Popular Books"),
              onTap: () {
                setState(() {
                  _currentIndex = 0; // Set the index to 0 for Popular Books
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text("New Arrival Books"),
              onTap: () {
                setState(() {
                  _currentIndex = 1; // Set the index to 1 for New Arrival Books
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text("Latest Books"), // Added Latest Books option
              onTap: () {
                setState(() {
                  _currentIndex = 2; // Set the index to 2 for Latest Books
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show Popular Books section
            SectionHeader(title: "Popular Books"),
            Container(
              height: 250, // Set a fixed height for the carousel
              child: PageView.builder(
                controller: _pageController,
                itemCount: 2, // Number of pages
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (innerIndex) => ProductCard()), // 2 products per row
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Add space between sections

            // Show New Arrival Books section
            SectionHeader(title: "New Arrival Books"),
            Container(
              height: 250, // Set a fixed height for the carousel
              child: PageView.builder(
                controller: _pageController,
                itemCount: 2, // Number of pages
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (innerIndex) => ProductCard()), // 2 products per row
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Add space between sections

            // Show Latest Books section
            SectionHeader(title: "Latest Books"),
            Container(
              height: 250, // Set a fixed height for the carousel
              child: PageView.builder(
                controller: _pageController,
                itemCount: 2, // Number of pages
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(2, (innerIndex) => ProductCard()), // 2 products per row
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _showBottomBar
          ? BottomBarDefault(
        items: items,
        backgroundColor: Colors.grey,  // Keeping the bottom bar color as is
        color: Colors.white,  // White icons
        colorSelected: Colors.black,  // Active icon color
        indexSelected: visit,
        paddingVertical: 25,
        onTap: (int index) => setState(() => visit = index),
      )
          : null,
    );
  }

  void _checkUserStatus() {
    if (_user == null) Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomePage()), (route) => false);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Placeholder image
          Image.asset('assets/images/book_image_01.jpg', height: 100, width: 100, fit: BoxFit.cover),
          SizedBox(height: 10),
          Text('Sample Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
          SizedBox(height: 5),
          Text('\$99.99', style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
