import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as devtools;
import 'package:spm_project/component/button.dart';
import 'package:spm_project/component/voice.dart';
import 'package:spm_project/helper/camera_helper.dart';
import 'package:spm_project/helper/database_helper.dart';

class CurrancyObj extends StatefulWidget {
  const CurrancyObj({super.key});

  @override
  State<CurrancyObj> createState() => _CurrancyObjState();
}

class _CurrancyObjState extends State<CurrancyObj> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool _modelLoaded = false;

  final CameraHelper _cameraHelper = CameraHelper();
  final FlutterTts _flutterTts = FlutterTts();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model3/model_unquant.tflite",
      labels: "assets/model3/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    if (res == null) {
      devtools.log("Failed to load the Currancy model");
      return;
    }
    devtools.log("Currancy Model loaded successfully");
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
    uid = FirebaseAuth.instance.currentUser!.uid;
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
    _speak("Detected object: $label");
  }

  Future<void> _captureImage() async {
    await _ensureModelIsLoaded();
    await _cameraHelper.captureImage(_updateImageFile, _updateLabel);
    await _databaseHelper.saveDetectedShape(filePath, label);

    // Add a small delay to ensure label is updated before navigating
    //await Future.delayed(Duration(milliseconds: 2000));
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      int result = await _flutterTts.speak(text);
      if (result == 1) {
        devtools.log("Speech started");
      } else {
        devtools.log("Speech failed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CURRANCY OBJECTS"),
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
