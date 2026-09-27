import 'package:compreface_fr/screens/detect_screen.dart';
import 'package:compreface_fr/screens/logs_screen.dart';
import 'package:compreface_fr/screens/settings_screen.dart';
import 'package:compreface_fr/screens/users_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please identify yourself using detect button',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildFeatureCard(
                  context,
                  'Users',
                  Icons.group,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UsersScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Detect',
                  Icons.face,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetectScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Logs',
                  Icons.storage,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogsScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Settings',
                  Icons.settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.green,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
