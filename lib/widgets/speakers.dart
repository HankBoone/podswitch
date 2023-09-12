import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class SpeakersWidget extends StatefulWidget {
  const SpeakersWidget({Key? key}) : super(key: key);

  @override
  SpeakersWidgetState createState() => SpeakersWidgetState();
}

class SpeakersWidgetState extends State<SpeakersWidget> {
  bool _speakersAreMuted = false; // Initial state

  @override
  void initState() {
    super.initState();
    _updateSpeakersState();
  }

  // Function to update the speakers state
  Future<void> _updateSpeakersState() async {
    final speakersState = await FlutterVolumeController.getMute();
    if (speakersState == true) {
      setState(() {
        _speakersAreMuted = true;
      });
    } else if (speakersState == false) {
      setState(() {
        _speakersAreMuted = false;
      });
    }
  }

  // Function to toggle the speakers state
  Future<void> _toggleSpeakersState() async {
    await FlutterVolumeController.setMute(!_speakersAreMuted);
    setState(() {
      _speakersAreMuted = !_speakersAreMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Display speakers state (you can use an icon or text)

        // Button to update speakers state
        ElevatedButton(
            onPressed: _toggleSpeakersState,
            child: Row(
              children: [
                Icon(
                  _speakersAreMuted ? Icons.mic_off : Icons.mic,
                  color: _speakersAreMuted ? Colors.red : Colors.green,
                ),
                Text(
                  _speakersAreMuted ? 'Unmute Speakers' : 'Mute Speakers',
                ),
              ],
            )),
      ],
    );
  }
}
