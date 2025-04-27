import 'package:flutter/material.dart';

import '../bluetooth_control/voice_control.dart';
import '../data/remote/firestore_service.dart';

class MicControl extends StatefulWidget {
  @override
  State<MicControl> createState() => _MicControlState();
}

class _MicControlState extends State<MicControl>
    with SingleTickerProviderStateMixin {
  late VoiceControl _voiceControl;
  bool isListening = false;
  String spokenText = '';
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _voiceControl = VoiceControl(
      onCommandReceived: _handleVoiceCommand,
      onSpeechChanged: (text) {
        setState(() {
          spokenText = text;
        });
      },
    );
  }

  void _handleVoiceCommand(String command) async {
    final actions = await _voiceControl.processVoiceCommand(command);

    for (var action in actions) {
      final port = action.key;
      final turnOn = action.value;
      _firestoreService.updateDeviceByPortGlobal(port, turnOn);
      debugPrint("🎯 UI update for device $port: ${turnOn ? 'BẬT' : 'TẮT'}");
    }

    setState(() {
      isListening = false;
      spokenText = '';
    });
  }

  void _toggleListening() {
    if (isListening) {
      _voiceControl.stopListening();
    } else {
      _voiceControl.startListening();
    }

    setState(() {
      isListening = !isListening;
      if (!isListening) spokenText = '';
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (spokenText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '"$spokenText"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        FloatingActionButton(
          onPressed: _toggleListening,
          backgroundColor: isListening ? Colors.red : Colors.blue,
          child: Icon(
            isListening ? Icons.mic_none : Icons.mic,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}
