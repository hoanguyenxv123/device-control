import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:test_control/common_widget/mic_control.dart';
import 'package:test_control/screens/home/widgets/header_part.dart';
import 'package:test_control/screens/home/widgets/your_room.dart';

import '../../data/remote/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void checkSpeechSupport() async {
    SpeechToText speech = SpeechToText();
    bool available = await speech.initialize(
      onError: (error) => print("SpeechToText Error: ${error.errorMsg}"),
      onStatus: (status) => print("SpeechToText Status: $status"),
    );

    if (!available) {
      print("❌ Thiết bị không hỗ trợ Speech-to-Text.");
    } else {
      print("✅ Speech-to-Text hoạt động.");
    }
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      print("✅ Quyền micro đã được cấp!");
      checkSpeechSupport(); // Kiểm tra sau khi có quyền
    } else {
      print("❌ Quyền micro bị từ chối!");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSpeechSupport();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
    return Scaffold(
      body: Column(children: [HeaderPart(), Expanded(child: YourRoom())]),
      floatingActionButton: MicControl(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
