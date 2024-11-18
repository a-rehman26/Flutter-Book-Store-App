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
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // // Function to handle the search query
  // void _searchBooks(String query) {
  //   showSearch(context: context, delegate: BookSearchDelegate(query));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Store"),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(
    icon: Icon(Icons.search),
    onPressed: () {
      showSearch(
        context: context,
        delegate: BookSearchDelegate(), // Call the search delegate here
      );
    },
          ),
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
                PopupMenuItem(
                  value: _user != null ? 'profile' : 'login',
                  child: Text(_user != null ? "Hello, ${_user!.email}" : "Login"),
                ),
                if (_user != null)
                  PopupMenuItem(
                    value: 'logout',
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

        return GridView.builder(
          shrinkWrap: true, // To make it scrollable inside SingleChildScrollView
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ProductCard(
              name: book['name'] ?? 'Unknown',
              desc: book['description'] ?? '',
              price: book['price'] ?? '0.0',
              image: book['image'] ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(
                      name: book['name'] ?? 'Unknown',
                      desc: book['description'] ?? '',
                      price: book['price'] ?? '0.0',
                      image: book['image'] ?? '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String desc;
  final String image;
  final VoidCallback onTap;

  const ProductCard({
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                return Image.asset('assets/images/book_image_01.jpg',
                    height: 100, width: 100, fit: BoxFit.cover);
              },
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              '\$$price',
              style: TextStyle(
                  fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final String name;
  final String desc;
  final String price;
  final String image;

  const BookDetailsScreen({
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                image,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/book_image_01.jpg',
                      height: 200, width: 200, fit: BoxFit.cover);
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '\$$price',
              style: TextStyle(
                  fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Text(
              desc,
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('$name added to cart'),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Add to Cart"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Proceeding to buy $name'),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Buy Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




class BookSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Clear button in search field
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query when pressed
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search when pressed
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Firebase query that searches for books whose name contains the query string (case-insensitive)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('name', isGreaterThanOrEqualTo: query.toLowerCase()) // Search for books that start with or contain the query
          .where('name', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff') // Ensure the range includes all matches
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No books found'));
        }
        final books = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ProductCard(
              name: book['name'] ?? 'Unknown',
              desc: book['description'] ?? '',
              price: book['price'] ?? '0.0',
              image: book['image'] ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(
                      name: book['name'] ?? 'Unknown',
                      desc: book['description'] ?? '',
                      price: book['price'] ?? '0.0',
                      image: book['image'] ?? '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Use StreamBuilder to filter books based on query entered
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .where('name', isGreaterThanOrEqualTo: query)  // Query for books starting with the query
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')  // Allow for case-insensitive search
          .snapshots(),
      builder: (context, snapshot) {
        // Loading indicator while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // If no data or no matching books
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No books found'));
        }

        // If books are found, display them in a GridView
        final books = snapshot.data!.docs;

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7, // Adjust the aspect ratio of the cards
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ProductCard(
              name: book['name'] ?? 'Unknown',
              desc: book['description'] ?? '',
              price: book['price'] ?? '0.0',
              image: book['image'] ?? '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(
                      name: book['name'] ?? 'Unknown',
                      desc: book['description'] ?? '',
                      price: book['price'] ?? '0.0',
                      image: book['image'] ?? '',
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
