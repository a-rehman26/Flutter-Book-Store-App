import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final String bookId;
  final String desc; // Add description field to display detailed info

  const BookDetailsScreen({
    required this.name,
    required this.price,
    required this.image,
    required this.bookId,
    required this.desc,
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
            // Book image
            Center(
              child: Image.network(
                image,
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/book_image_01.jpg', height: 200, width: 150, fit: BoxFit.cover);
                },
              ),
            ),
            SizedBox(height: 20),
            // Book name
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Book price
            Text(
              '\$$price',
              style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            // Book description
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              desc,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Add to Cart button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logic to add book to cart (you can add Firebase logic here)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name added to cart!')),
                  );
                },
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  // primary: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<DocumentSnapshot> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      setState(() {
        cartItems = cartSnapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: cartItems.isEmpty
          ? Center(child: Text('No items in your cart'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];

          // Determine image to display
          final imageUrl = cartItem['image'] ?? '';
          final imageWidget = (imageUrl.isNotEmpty)
              ? Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
              : Image.asset(
            'assets/images/book_image_01.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );

          return ListTile(
            title: Text(cartItem['name']),
            subtitle: Text('\$${cartItem['price']}'),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () async {
                // Remove item from cart
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('cart')
                    .doc(cartItem.id)
                    .delete();
                _fetchCartItems(); // Refresh the cart
              },
            ),
          );
        },
      ),
    );
  }
}

class BookListScreen extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final String bookId;
  final String desc; // Description field from the Firestore document

  BookListScreen({
    required this.name,
    required this.price,
    required this.image,
    required this.bookId,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
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
              desc: desc, // Passing the description
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Image.network(image),
            Text(name),
            Text('\$$price'),
          ],
        ),
      ),
    );
  }
}


class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
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

  // Remove item from wishlist
  Future<void> _removeFromWishlist(String bookId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc(bookId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed from Wishlist")));
      } catch (e) {
        print("Error removing from wishlist: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to remove from Wishlist")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
        backgroundColor: Colors.grey[800],
      ),
      body: _user == null
          ? Center(child: Text("Please log in to view your wishlist"))
          : FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('wishlist')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Your wishlist is empty"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final book = snapshot.data!.docs[index];
              final bookId = book['bookId'];
              final bookName = book['name'] ?? 'No name';
              final bookPrice = book['price'] ?? 'No price';
              final bookImage = book['image'] ?? 'assets/images/book_image_01.jpg';

              return ListTile(
                leading: Image.network(bookImage, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(bookName),
                subtitle: Text("\$$bookPrice"),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeFromWishlist(bookId),
                ),
                onTap: () {
                  // Navigate to book details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(
                        name: bookName,
                        price: bookPrice,
                        image: bookImage,
                        bookId: bookId,
                        desc: book['description'] ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}