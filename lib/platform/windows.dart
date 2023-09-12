import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WindowsPlatform {
  // Define a MethodChannel for communication with the platform.
  static const MethodChannel _channel = MethodChannel('app.nordbot.podswitch');

  // Function to get the microphone state and return it to the caller.
  static Future<bool> getMicrophoneState() async {
    try {
      // Invoke the platform method to get the microphone state.
      final bool result = await _channel.invokeMethod('getMicrophoneState');
      return result;
    } on PlatformException catch (e) {
      // Handle any platform-specific errors here.
      if (kDebugMode) {
        print('Error getting microphone state: $e');
      }
      return false; // You can return an appropriate default value in case of an error.
    }
  }

  // Function to toggle the microphone state and return the new state.
  static Future<bool> toggleMicrophone() async {
    try {
      // Invoke the platform method to toggle the microphone state.
      final bool result = await _channel.invokeMethod('toggleMicrophone');
      return result;
    } on PlatformException catch (e) {
      // Handle any platform-specific errors here.
      if (kDebugMode) {
        print('Error toggling microphone state: $e');
      }
      return false; // You can return an appropriate default value in case of an error.
    }
  }
}
