import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer' as devtools;
import 'package:spm_project/component/button.dart';
import 'package:spm_project/component/voice.dart';
import 'package:spm_project/helper/camera_helper.dart';
import '../ai_explain/ChatScreen.dart'; // Import the ChatScreen to navigate to it

class MathsObj extends StatefulWidget {
  const MathsObj({super.key});

  @override
  State<MathsObj> createState() => _MathsObjState();
}

class _MathsObjState extends State<MathsObj> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool _modelLoaded = false;

  final CameraHelper _cameraHelper = CameraHelper();

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model1/model_unquant.tflite",
      labels: "assets/model1/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    if (res == null) {
      devtools.log("Failed to load the Maths model");
      return;
    }
    devtools.log("Maths Model loaded successfully");
  }

  Future<void> _ensureModelIsLoaded() async {
    if (!_modelLoaded) {
      await _tfliteInit();
      setState(() {
        _modelLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tfliteInit();
    _cameraHelper.initializeCamera().then((_) {
      setState(() {}); // Rebuild the UI after camera initialization
    });
  }

  @override
  void dispose() {
    _cameraHelper.disposeCamera();
    Tflite.close();
    super.dispose();
  }

  void _updateImageFile(File newFile) {
    setState(() {
      filePath = newFile;
    });
  }

  void _updateLabel(String newLabel) {
    setState(() {
      label = newLabel;
    });
  }

  void _navigateToChatScreen() {
    // Navigate to the ChatScreen and pass the detected object (label)
    if (label.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(identifiedObject: label),
        ),
      );
    } else {
      // If no object is detected, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No object detected yet!')),
      );
    }
  }

  Future<void> _captureImage() async {
    await _ensureModelIsLoaded();
    await _cameraHelper.captureImage(_updateImageFile, _updateLabel);

    // Add a small delay to ensure label is updated before navigating
    await Future.delayed(Duration(milliseconds: 1000));

    // Navigate to ChatScreen after the label is updated
    if (label.isNotEmpty) {
      _navigateToChatScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No object detected yet!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MATHS OBJECTS"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_cameraHelper.isCameraInitialized &&
                  _cameraHelper.cameraController != null)
                SizedBox(
                  width: 400,
                  height: 600,
                  child: AspectRatio(
                    aspectRatio:
                        _cameraHelper.cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraHelper.cameraController!),
                  ),
                )
              else
                const CircularProgressIndicator(),
              SizedBox(height: screenHeight * 0.01),
              if (label.isNotEmpty)
                Text(
                  "Detected Object: $label",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: screenHeight * 0.01),
              CustomButton(
                ontap: () async {
                  await _captureImage();
                },
                text: "Identify",
              ),
              SizedBox(height: screenHeight * 0.01),
              SpeechButton(onCaptureCommand: _captureImage),
            ],
          ),
        ),
      ),
    );
  }
}
