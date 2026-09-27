import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _baseUrlController = TextEditingController();
  TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> checkConnection() async {
    final String baseUrl = _baseUrlController.text;
    final String apiKey = _apiKeyController.text;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/ping'), // Sesuaikan dengan endpoint yang tersedia di API Anda
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        // Koneksi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection successful!')),
        );
      } else {
        // Gagal terhubung
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Set nilai default jika tidak ada data yang disimpan
    setState(() {
      _baseUrlController.text = prefs.getString('baseUrl') ??
          'https://3103-36-85-109-211.ngrok-free.app';
      _apiKeyController.text =
          prefs.getString('apiKey') ?? '14de94a1-feb0-4b22-9bdd-f11fa69598b4';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', _baseUrlController.text);
    await prefs.setString('apiKey', _apiKeyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                hintText: 'Enter the API Base URL',
              ),
            ),
            SizedBox(height: 4),
            Text(
              'cth. https://6e11-36-85-111-237.ngrok-free.app',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter the API Key',
              ),
            ),
            SizedBox(height: 4),
            Text(
              'cth. 14de94a1-feb0-4b22-9bdd-f11fa69598b4',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Save'),
            ),
            SizedBox(height: 16),

            // Tombol "Test Connection"
            ElevatedButton(
              onPressed: checkConnection,
              child: Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
