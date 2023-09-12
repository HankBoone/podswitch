import 'package:flutter/material.dart';
import 'package:podswitch/platform/windows.dart';

class MicrophoneWidget extends StatefulWidget {
  const MicrophoneWidget({Key? key}) : super(key: key);

  @override
  MicrophoneWidgetState createState() => MicrophoneWidgetState();
}

class MicrophoneWidgetState extends State<MicrophoneWidget> {
  bool _microphoneState = false; // Initial state

  @override
  void initState() {
    _updateMicrophoneState();
    super.initState();
  }

  // Function to update the microphone state
  Future<void> _updateMicrophoneState() async {
    final microphoneState = await WindowsPlatform.getMicrophoneState();
    setState(() {
      _microphoneState = microphoneState;
    });
  }

  // Function to toggle the microphone state
// Function to toggle the microphone state
  Future<void> _toggleMicrophoneState() async {
    await WindowsPlatform.toggleMicrophone();
    await _updateMicrophoneState();
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
                  _microphoneState ? Icons.mic : Icons.mic_off,
                  color: _microphoneState ? Colors.green : Colors.red,
                ),
                Text(
                  _microphoneState ? 'Mute Microphone' : 'Unmute Microphone',
                  style: TextStyle(
                    color: _microphoneState ? Colors.green : Colors.red,
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
