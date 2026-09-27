import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  String? baseUrl;
  String? recognitionApiKey;

  UserService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedBaseUrl = prefs.getString('baseUrl') ?? '';

    // Check and add 'https://' if not present
    if (!storedBaseUrl.startsWith('http://') &&
        !storedBaseUrl.startsWith('https://')) {
      storedBaseUrl = 'https://$storedBaseUrl';
    }

    baseUrl = storedBaseUrl;
    recognitionApiKey = prefs.getString('apiKey') ?? '';
  }

  Future<void> initialize() async {
    await _loadSettings();
  }

  Future<List<String>> fetchUsers() async {
    await _loadSettings();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/recognition/subjects'),
      headers: {
        'x-api-key': recognitionApiKey!,
      },
    );

    // Debug log untuk melihat isi respons
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('subjects') && data['subjects'] is List) {
        return List<String>.from(data['subjects']);
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> addUser(String username) async {
    await _loadSettings();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/recognition/subjects'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': recognitionApiKey!,
      },
      body: json.encode({"subject": username}),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to add user');
    }
  }

  Future<void> addPhoto(String username, File imageFile) async {
    await _loadSettings();
    final url = "$baseUrl/api/v1/recognition/faces?subject=$username";
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['x-api-key'] = recognitionApiKey!;
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception('Failed to upload photo');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPhotos(String username,
      {int page = 0, int size = 10}) async {
    await _loadSettings();
    final url =
        "$baseUrl/api/v1/recognition/faces?page=$page&size=$size&subject=$username";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': recognitionApiKey!,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['faces']);
    } else {
      throw Exception('Failed to load user photos');
    }
  }

  Future<void> deletePhoto(String imageId) async {
    await _loadSettings();
    final url = "$baseUrl/api/v1/recognition/faces/$imageId";
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'x-api-key': recognitionApiKey!,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo');
    }
  }

  String getImageUrl(String imageId) {
    return "$baseUrl/api/v1/static/$recognitionApiKey/images/$imageId";
  }
}
