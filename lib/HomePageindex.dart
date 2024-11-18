import 'package:aptech_e_project_flutter/Auth/login.dart';
import 'package:aptech_e_project_flutter/Auth/welcomePage.dart';
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


  // Add to Wishlist
  void _addToWishlist(BuildContext context, String bookId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Show a message that the user needs to log in
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please log in to add to Wishlist."),
      ));
    } else {
      // Add to wishlist if user is logged in
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc(bookId)
            .set({
          'bookId': bookId,
          'addedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Wishlist")));
      } catch (e) {
        print("Error adding to wishlist: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add to Wishlist")));
      }
    }
  }

// Add to Cart
  void _addToCart(BuildContext context, String bookId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Show a message that the user needs to log in
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please log in to add to Cart."),
      ));
    } else {
      // Add to cart if user is logged in
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(bookId)
            .set({
          'bookId': bookId,
          'addedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Cart")));
      } catch (e) {
        print("Error adding to cart: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add to Cart")));
      }
    }
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
                      MaterialPageRoute(builder: (context) => WishlistScreen()),
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
            BooksSection(category: "Popular Book", addToWishlist: _addToWishlist, addToCart: _addToCart),
            SizedBox(height: 20),
            SectionHeader(title: "Latest Books/New Arrival"),
            BooksSection(category: "Latest Books/New Arrival", addToWishlist: _addToWishlist, addToCart: _addToCart),
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
  final String? image;
  final String bookId;
  final String desc;
  final Function(BuildContext, String) addToWishlist;
  final Function(BuildContext, String) addToCart;

  const ProductCard({
    required this.name,
    required this.price,
    this.image,
    required this.bookId,
    required this.desc,
    required this.addToWishlist,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    final displayImage = (image != null && image!.isNotEmpty)
        ? Image.network(image!, fit: BoxFit.cover)
        : Image.asset('assets/images/book_image_01.jpg', fit: BoxFit.cover);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              name: name,
              price: price,
              image: image ?? 'assets/images/book_image_01.jpg',
              bookId: bookId,
              desc: desc,
            ),
          ),
        );
      },
      child: Container(
        width: 150, // Reduced width to make the cards smaller
        padding: EdgeInsets.all(8), // Reduced padding
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Slightly reduced border radius
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Lighter shadow for subtle effect
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Rounded corners for image
                child: displayImage,
              ),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // Avoid overflow if the text is too long
            ),
            SizedBox(height: 4),
            Text(
              '\$ $price',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spaced buttons
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    addToWishlist(context, bookId);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.blue),
                  onPressed: () {
                    addToCart(context, bookId);
                  },
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
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class BooksSection extends StatelessWidget {
  final String category;
  final Function(BuildContext, String) addToWishlist;
  final Function(BuildContext, String) addToCart;

  const BooksSection({
    required this.category,
    required this.addToWishlist,
    required this.addToCart,
  });

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
          return Center(child: Text("No books available"));
        }

        final books = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final bookId = book.id;
            final bookData = book.data() as Map<String, dynamic>;
            final name = bookData['name'] ?? 'No Title';
            final price = bookData['price'] ?? 'No Price';
            final image = bookData['image'] ?? '';
            final desc = bookData['description'] ?? 'No Description';

            return ProductCard(
              name: name,
              price: price,
              image: image,
              bookId: bookId,
              desc: desc,
              addToWishlist: addToWishlist,
              addToCart: addToCart,
            );
          },
        );
      },
    );
  }
}
