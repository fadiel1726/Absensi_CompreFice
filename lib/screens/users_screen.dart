import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'add_user_screen.dart';
import 'user_details_screen.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  late Future<List<String>> _users;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeUserService();
  }

  Future<void> _initializeUserService() async {
    await _userService.initialize();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      _users = _userService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddUser,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Initialization Error: ${snapshot.error}'),
            );
          } else {
            return FutureBuilder<List<String>>(
              future: _users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load users: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users found'));
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(users[index]),
                        onTap: () => _navigateToUserDetails(users[index]),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToAddUser() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddUserScreen(userService: _userService)),
    );
    _fetchUsers(); // Refresh user list after adding a user
  }

  void _navigateToUserDetails(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              UserDetailsScreen(username: username, userService: _userService)),
    );
  }
}
