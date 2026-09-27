import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livelyness_detection/livelyness_detection.dart';

class DetectScreen extends StatefulWidget {
  @override
  _DetectScreenState createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isDetecting = false;
  String _result = '';
  bool _isFrontCamera = false;

  List<CameraDescription>? cameras;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _startCamera(_isFrontCamera ? cameras!.last : cameras!.first);
    }
  }

  void _startCamera(CameraDescription camera) {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _cameraController.dispose();
    _startCamera(_isFrontCamera ? cameras!.last : cameras!.first);
  }

  Future<void> _startLivenessDetection() async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
      _result = 'Detecting...';
    });

    try {
      // Start Liveness Detection
      final CapturedImage? response =
          await LivelynessDetection.instance.detectLivelyness(
        context,
        config: DetectionConfig(
          steps: [
            LivelynessStepItem(
                step: LivelynessStep.blink,
                title: "Berkedip",
                isCompleted: false),
            LivelynessStepItem(
                step: LivelynessStep.smile,
                title: "Senyum",
                isCompleted: false),
          ],
          startWithInfoScreen: true,
          showFacialVertices: true,
          maxSecToDetect: 30,
          captureButtonColor: Colors.red,
        ),
      );

      if (response == null) {
        setState(() {
          _result = 'Liveness detection failed.';
        });
        return;
      }

      _capturedImagePath = response.imgPath;

      // Proceed with face recognition using the captured image
      final tempFile = File(_capturedImagePath!);
      final recognitionResult = await _detectFace(tempFile);

      setState(() {
        _result = recognitionResult ?? 'No face detected or unknown error.';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<String?> _detectFace(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl') ?? '';
    final apiKey = prefs.getString('apiKey') ?? '';

    final url = Uri.parse(
        '$baseUrl/api/v1/recognition/recognize?limit=1&det_prob_threshold=0.8&prediction_count=1');
    final request = http.MultipartRequest('POST', url);
    request.headers['x-api-key'] = apiKey;
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data['result'].isNotEmpty) {
        final result = data['result'][0];
        final subject = result['subjects'][0]['subject'];
        final similarity =
            (result['subjects'][0]['similarity'] * 100).toStringAsFixed(2);
        final probability =
            (result['box']['probability'] * 100).toStringAsFixed(2);

        return 'Detected: $subject\nSimilarity: $similarity%\nProbability: $probability%';
      } else {
        return 'No face detected.';
      }
    } else {
      return 'Failed to recognize face. Status code: ${response.statusCode}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Recognition"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startLivenessDetection,
                child: Text(_isDetecting ? 'Detecting...' : 'Start Detection'),
              ),
              SizedBox(height: 20),
              if (_capturedImagePath != null)
                Image.file(
                  File(_capturedImagePath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),
              Text(_result, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
