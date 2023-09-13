import 'package:flutter/foundation.dart';
import 'package:win_ble/win_ble.dart';

class Bluetooth {
  BleState bleState = BleState.On;
  List<BleDevice> devices = <BleDevice>[];

  late Stream<Map<String, dynamic>> _connectionStream;

  // Singleton instance
  static final Bluetooth _instance = Bluetooth._internal();

  Bluetooth._internal() {
    _connectionStream = WinBle.connectionStream;
  }

  factory Bluetooth() {
    return _instance;
  }

  Stream<bool> connectionStreamOf(String deviceAddress) {
    return _connectionStream.map((event) => event['connected']);
  }

  Future<void> initialize() async {
    await WinBle.initialize(serverPath: "BLEServer.exe", enableLog: true);
  }

  Future<void> updateBluetoothState(bool isEnabled) async {
    bleState = isEnabled ? BleState.On : BleState.Off;
    await WinBle.updateBluetoothState(isEnabled);
  }

  void startScanning() {
    if (bleState == BleState.On) {
      try {
        WinBle.startScanning();
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      if (kDebugMode) {
        print("Bluetooth is off");
      }
    }
  }

  void stopScanning() {
    try {
      WinBle.stopScanning();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> connectDevice(BleDevice device) async {
    try {
      await WinBle.connect(device.address);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> disconnectDevice(BleDevice device) async {
    try {
      await WinBle.disconnect(device.address);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> canPairDevice(BleDevice device) async {
    try {
      bool pairable = await WinBle.canPair(device.address);
      return pairable;
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return false;
      }
      return false;
    }
  }

  Future<bool> isDevicePaired(BleDevice device) async {
    try {
      bool paired = await WinBle.isPaired(device.address);
      return paired;
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return false;
      }
      return false;
    }
  }

  pairDevice(BleDevice device) async {
    try {
      await WinBle.pair(device.address);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> unpairDevice(BleDevice device) async {
    try {
      await WinBle.unPair(device.address);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void dispose() {
    WinBle.dispose();
  }
}
