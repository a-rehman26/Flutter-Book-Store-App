import 'package:aptech_e_project_flutter/Auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Listen to the auth state changes using 'authStateChanges()'
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  // Function to logout
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Function to navigate to login screen if user is not logged in
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Store"),
        backgroundColor: Colors.grey[800],
        actions: [
          // Show profile or login option based on user's authentication state
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.account_circle, color: Colors.black),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'login') {
                _navigateToLogin();
              }
            },
            itemBuilder: (context) {
              return [
                // Show the user's email if logged in, otherwise show "Login"
                PopupMenuItem(
                  value: _user != null ? 'profile' : 'login', // Set value based on login state
                  child: Text(_user != null ? "Hello, ${_user!.email}" : "Login"),
                ),
                // Show the "Logout" option only if the user is logged in
                if (_user != null)
                  PopupMenuItem(
                    value: 'logout', // Set value as 'logout' for logout action
                    child: Text("Logout"),
                  ),
              ];
            },
          ),


        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: "Popular Books"),
            BooksSection(category: "Popular Book"),
            SizedBox(height: 20),
            SectionHeader(title: "Latest Books/New Arrival"),
            BooksSection(category: "Latest Books/New Arrival"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Shop"),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BooksSection extends StatelessWidget {
  final String category;

  const BooksSection({required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No books found in this category'));
        }
        final books = snapshot.data!.docs;

        return Container(
          height: 250,
          child: PageView.builder(
            itemCount: (books.length / 2).ceil(),
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: books
                    .skip(index * 2)
                    .take(2)
                    .map(
                      (book) => ProductCard(
                    name: book['name'] ?? 'Unknown',
                    price: book['price'] ?? '0.0',
                    image: book['image'] ?? '',
                  ),
                )
                    .toList(),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const ProductCard({required this.name, required this.price, required this.image});

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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.network(
            image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/book_image_01.jpg', height: 100, width: 100, fit: BoxFit.cover);
            },
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            '\$$price',
            style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
