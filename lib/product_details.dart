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
          return ListTile(
            title: Text(cartItem['name']),
            subtitle: Text('\$${cartItem['price']}'),
            leading: Image.network(cartItem['image'], width: 50),
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
