import 'package:aptech_e_project_flutter/Auth/login.dart';
import 'package:aptech_e_project_flutter/Auth/welcomePage.dart';
// import 'package:aptech_e_project_flutter/cart_screen.dart';
// import 'package:aptech_e_project_flutter/wishlist_screen.dart';
import 'package:aptech_e_project_flutter/product_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  int _cartCount = 0;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
    _getCartCount();
    _getWishlistCount();
  }

  // Get the count of items in the cart
  Future<void> _getCartCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();
      setState(() {
        _cartCount = cartSnapshot.docs.length;
      });
    }
  }

  // Get the count of items in the wishlist
  Future<void> _getWishlistCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final wishlistSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();
      setState(() {
        _wishlistCount = wishlistSnapshot.docs.length;
      });
    }
  }

  // Log out the user
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  // Navigate to LoginPage
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
        backgroundColor: Colors.grey[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Book Store", style: TextStyle(color: Colors.white)),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: PopupMenuButton(
                    icon: const Icon(Icons.account_circle, color: Colors.black),
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
                          child: Text(
                            _user != null
                                ? "Hello, ${_user!.email?.split('@')[0]}"
                                : "Login",
                          ),
                        ),
                        if (_user != null)
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text("Logout"),
                          ),
                      ];
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Cart Icon
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      if (_cartCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              _cartCount.toString(),
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    // Navigate to Cart screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // Wishlist Icon
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white),
                      if (_wishlistCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              _wishlistCount.toString(),
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    // Navigate to Wishlist screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? image;  // Make this nullable, as it can be null if image URL is not available
  final String bookId;

  const ProductCard({
    required this.name,
    required this.price,
    this.image,  // Image URL or null
    required this.bookId,
  });

  Future<void> _addToWishlist(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add items to wishlist")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(bookId)
          .set({
        'bookId': bookId,
        'name': name,
        'price': price,
        'image': image ?? 'assets/book_image_01.jpg',  // Fallback to local image if null
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added to wishlist")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding to wishlist: $e")),
      );
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add items to cart")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(bookId)
          .set({
        'bookId': bookId,
        'name': name,
        'price': price,
        'image': image ?? 'assets/book_image_01.jpg',  // Fallback to local image if null
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added to cart")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding to cart: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use network image if available, otherwise use local asset image
    final displayImage = (image != null && image!.isNotEmpty)
        ? Image.network(image!, height: 120, width: 120, fit: BoxFit.cover)  // Set fixed height and width
        : Image.asset('assets/images/book_image_01.jpg', height: 120, width: 120, fit: BoxFit.cover);  // Fallback to local asset image

    return GestureDetector(
      onTap: () {
        // Navigate to book details screen or handle any other action
      },
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
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures the column doesn't take up too much space
          children: [
            // Image Section
            displayImage,
            SizedBox(height: 10),

            // Name and Price Section
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "\$$price",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Action Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () => _addToWishlist(context),
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => _addToCart(context),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BooksSection extends StatelessWidget {
  final String category;

  const BooksSection({required this.category});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('books')
          .where('category', isEqualTo: category)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No books found"));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final book = snapshot.data!.docs[index];
            return ProductCard(
              name: book['name'],
              price: book['price'],
              image: book['image'],
              bookId: book.id,
            );
          },
        );
      },
    );
  }
}
