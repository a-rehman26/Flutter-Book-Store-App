import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(Icons.account_circle, size: 28),
              items: [
                // DropdownMenuItem(child: Text("Profile"), value: "profile"),
                DropdownMenuItem(child: Text("Logout"), value: "logout"),
              ],
              onChanged: (value) {
                if (value == "logout") {
                  // Add logout functionality here
                }
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24, color: Colors.white)),
              decoration: BoxDecoration(color: Colors.orangeAccent),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Books'),
              onTap: () {
                // Add navigation to Add Books
              },
            ),
            ListTile(
              leading: Icon(Icons.update),
              title: Text('Update Books'),
              onTap: () {
                // Add navigation to Update Books
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Books'),
              onTap: () {
                // Add navigation to Delete Books
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Dashboard',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
