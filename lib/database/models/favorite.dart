import 'dart:typed_data';

import 'package:win_ble/win_ble.dart';
import 'dart:convert';

class Favorite extends BleDevice {
  final int id;

  Favorite({
    required this.id,
    required String address,
    required String rssi,
    required String timestamp,
    required String advType,
    required String name,
    required List<String> serviceUuids,
    required Uint8List manufacturerData,
  }) : super(
          address: address,
          rssi: rssi,
          timestamp: timestamp,
          advType: advType,
          name: name,
          serviceUuids: serviceUuids,
          manufacturerData: manufacturerData,
        );

  factory Favorite.fromSqfliteDatabase(Map<String, dynamic> map) {
    final List<dynamic>? serviceUuidsJson =
        map['serviceUuids'] != null ? json.decode(map['serviceUuids']) : null;
    final List<String> serviceUuids = serviceUuidsJson
            ?.map<String>((dynamic value) => value.toString())
            .toList() ??
        <String>[];

    final Uint8List manufacturerData = Uint8List.fromList(
      List<int>.from(map['manufacturerData']),
    );

    return Favorite(
      id: map['id']?.toInt() ?? 0,
      address: map['bluetoothAddress'] ?? '',
      rssi: map['rssi'] ?? '',
      timestamp: map['timestamp'] ?? '',
      advType: map['advType'] ?? '',
      name: map['localName'] ?? '',
      serviceUuids: serviceUuids,
      manufacturerData: manufacturerData,
    );
  }
}
