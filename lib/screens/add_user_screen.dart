import 'package:flutter/material.dart';
import '../services/user_service.dart';

class AddUserScreen extends StatefulWidget {
  final UserService userService;

  AddUserScreen({required this.userService});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _addUser() async {
    final username = _usernameController.text;
    if (username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a username')));
      return;
    }

    await widget.userService.addUser(username);
    Navigator.pop(context); // Return to user list screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: Text("Add User"),
            ),
          ],
        ),
      ),
    );
  }
}
