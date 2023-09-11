import 'dart:math';

import 'package:flutter/material.dart';
import 'package:podswitch/platform/windows.dart';

class MicrophoneWidget extends StatefulWidget {
  const MicrophoneWidget({Key? key}) : super(key: key);

  @override
  MicrophoneWidgetState createState() => MicrophoneWidgetState();
}

class MicrophoneWidgetState extends State<MicrophoneWidget> {
  bool _microphoneIsMuted = false; // Initial state

  @override
  void initState() {
    super.initState();
    _updateMicrophoneState();
  }

  // Function to update the microphone state
  Future<void> _updateMicrophoneState() async {
    final microphoneState = await WindowsPlatform.getMicrophoneState();
    if (microphoneState == true) {
      setState(() {
        _microphoneIsMuted = false;
      });
    } else if (microphoneState == false) {
      setState(() {
        _microphoneIsMuted = true;
      });
    }
  }

  // Function to toggle the microphone state
// Function to toggle the microphone state
  Future<void> _toggleMicrophoneState() async {
    var result = await WindowsPlatform.toggleMicrophone();
    if (result) {
      setState(() {
        _microphoneIsMuted = !_microphoneIsMuted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Display microphone state (you can use an icon or text)

        // Button to update microphone state
        ElevatedButton(
            onPressed: _toggleMicrophoneState,
            child: Row(
              children: [
                Icon(
                  _microphoneIsMuted ? Icons.mic_off : Icons.mic,
                  color: _microphoneIsMuted ? Colors.red : Colors.green,
                ),
                Text(
                  _microphoneIsMuted ? 'Unmute Microphone' : 'Mute Microphone',
                  style: TextStyle(
                    color: _microphoneIsMuted ? Colors.red : Colors.green,
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
