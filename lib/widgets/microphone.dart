import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:podswitch/platform/windows.dart';

class MicrophoneWidget extends StatefulWidget {
  const MicrophoneWidget({Key? key}) : super(key: key);

  @override
  MicrophoneWidgetState createState() => MicrophoneWidgetState();
}

class MicrophoneWidgetState extends State<MicrophoneWidget> {
  bool _microphoneState = false; // Explicitly initialize to false

  @override
  void initState() {
    _updateMicrophoneState();
    super.initState();
  }

  // Function to update the microphone state
  Future<void> _updateMicrophoneState() async {
    try {
      // Invoke the platform method to get the microphone state.
      bool? result = await WindowsPlatform.getMicrophoneState();
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _microphoneState = result ?? false;
        });
      } else {
        if (kDebugMode) {
          print('Widget is disposed. Cannot setState.');
        }
      }
    } on PlatformException catch (e) {
      // Handle any platform-specific errors here.
      if (kDebugMode) {
        print('Error getting microphone state: $e');
      }
    }
  }

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
