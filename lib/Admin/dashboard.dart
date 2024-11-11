import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference booksRef = FirebaseFirestore.instance.collection('books');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = "Popular Book";
  Uint8List? _imageFile; // Holds image data for web compatibility
  String? _editingBookId;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes(); // Convert to Uint8List for web compatibility
      setState(() {
        _imageFile = imageBytes;
      });
    }
  }

  // Adjust _uploadImage to handle Uint8List
  Future<String?> _uploadImage(Uint8List imageData) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('book_images/$fileName');
      // Use putData instead of putFile for Uint8List data
      await ref.putData(imageData);
      return await ref.getDownloadURL(); // Get the URL of the uploaded image
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }


  // Add or Update Book in Firestore
  Future<void> _saveBook() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required')));
      return;
    }

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      if (_editingBookId == null) {
        await booksRef.add({
          'name': _nameController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'category': _category,
          'image': imageUrl ?? '',
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book added successfully')));
      } else {
        await booksRef.doc(_editingBookId).update({
          'name': _nameController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'category': _category,
          if (imageUrl != null) 'image': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book updated successfully')));
      }
      _clearFields();
    } catch (e) {
      print("Failed to save book: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save book')));
    }
  }

  // Edit a Book
  void _editBook(DocumentSnapshot doc) {
    var book = doc.data() as Map<String, dynamic>;
    _nameController.text = book['name'];
    _priceController.text = book['price'];
    _descriptionController.text = book['description'];
    _category = book['category'];
    _editingBookId = doc.id;
  }

  // Delete a Book
  Future<void> _deleteBook(String docId, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }
      await booksRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book deleted successfully')));
    } catch (e) {
      print("Failed to delete book: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete book')));
    }
  }

  // Clear fields after adding/updating book
  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _category = "Popular Book";
    _imageFile = null;
    _editingBookId = null;
  }

  // Logout function
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Book Name")),
                TextField(controller: _priceController, decoration: InputDecoration(labelText: "Price")),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description")),
                DropdownButton<String>(
                  value: _category,
                  onChanged: (value) => setState(() => _category = value!),
                  items: ["Popular Book", "Latest Books/New Arrival"].map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick Image"),
                ),
                _imageFile != null ? Image.memory(_imageFile!, width: 100, height: 100) : Container(),
                ElevatedButton(
                  onPressed: _saveBook,
                  child: Text(_editingBookId == null ? "Add Book" : "Update Book"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: booksRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var book = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: book['image'] != null && book['image'].isNotEmpty
                          ? Image.network(book['image'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.book),
                      title: Text(book['name']),
                      subtitle: Text("Price: ${book['price']} | Category: ${book['category']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editBook(doc),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteBook(doc.id, book['image']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
