import 'dart:async';
import 'package:flutter/material.dart';
import 'package:win_ble/win_ble.dart';

import '../widgets/sidebar.dart';
import 'deviceinfo.dart';

class DeviceSelect extends StatefulWidget {
  const DeviceSelect({Key? key}) : super(key: key);
  @override
  State<DeviceSelect> createState() => _DeviceSelectState();
}

class _DeviceSelectState extends State<DeviceSelect> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription? scanStream;
  StreamSubscription? connectionStream;
  StreamSubscription? bleStateStream;
  static bool _isInitialized = false;

  bool isScanning = false;
  BleState bleState = BleState.On;
  Future<void> initialize() async {
    try {
      await WinBle.initialize(serverPath: "BLEServer.exe", enableLog: true);
      _isInitialized = true;
    } catch (e) {
      dispose();
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
    if (bleState == BleState.Unknown || bleState == BleState.Disabled) {
      setState(() {
        WinBle.updateBluetoothState(true);
      });
    }
    // Listen to Scan Stream , we can cancel it in dispose()
    scanStream = WinBle.scanStream.listen((event) {
      setState(() {
        final index =
            devices.indexWhere((element) => element.address == event.address);
        // Updating existing device
        if (index != -1) {
          final name = devices[index].name;
          devices[index] = event;
          // Putting back cached name
          if (event.name.isEmpty || event.name == 'N/A') {
            devices[index].name = name;
          }
        } else {
          devices.add(event);
        }
      });
    });

    // Listen to Ble State Stream
    bleStateStream = WinBle.bleState.listen((BleState state) {
      setState(() {
        bleState = state;
      });
    });

    // Initialize the Bluetooth state
    WinBle.bleState.first.then((state) {
      setState(() {
        bleState = state;
      });
    });

    // // Start scanning if Bluetooth is enabled
    // if (bleState == BleState.On) {
    //   startScanning();
    // }
  }

  String bleStatus = "";
  String bleError = "";

  List<BleDevice> devices = <BleDevice>[];

  /// Main Methods
  startScanning() {
    if (bleState != BleState.On) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please Check your Bluetooth , State : $bleState"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1)));
      return;
    }
    WinBle.startScanning();
    setState(() {
      isScanning = true;
    });
  }

  stopScanning() {
    WinBle.stopScanning();
    setState(() {
      isScanning = false;
    });
  }

  onDeviceTap(BleDevice device) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => DeviceInfo(
                device: device,
              )),
    );
    ();
  }

  @override
  void dispose() {
    scanStream?.cancel();
    connectionStream?.cancel();
    bleStateStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getBluetoothTextColor() {
      return bleState == BleState.On ? Colors.green : Colors.red;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open the drawer using the GlobalKey
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.bluetooth,
              size: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Devices'),
          ],
        ),
        centerTitle: true,
        actions: [
          kBButton(
            "Bluetooth : ",
            bleState == BleState.On ? "On" : "Off",
            () {},
            stateTextColor: getBluetoothTextColor(),
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: SizedBox(
        child: Column(
          children: [
            // Top Buttons
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isScanning
                    ? kButton(
                        "Stop Scan",
                        () {
                          stopScanning();
                        },
                        Colors.red,
                        textColor: Colors.white,
                        buttonIcon: Icons.stop,
                      )
                    : kButton(
                        "Start Scan",
                        () {
                          startScanning();
                        },
                        Colors.green,
                        textColor: Colors.white,
                        buttonIcon: Icons.play_arrow,
                      ),
                kButton(
                    bleState == BleState.On
                        ? "Turn off Bluetooth"
                        : "Turn on Bluetooth", () {
                  if (bleState == BleState.On) {
                    WinBle.updateBluetoothState(false).then((state) {
                      setState(() {
                        bleState = BleState.Off;
                      });
                    });
                  } else if (bleState == BleState.Off) {
                    WinBle.updateBluetoothState(true).then((state) {
                      setState(() {
                        bleState = BleState.On;
                      });
                    });
                  }
                }, Colors.blue),
              ],
            ),
            const Divider(),
            Column(
              children: [
                Text(bleStatus),
                Text(bleError),
              ],
            ),

            Expanded(
              child: devices.isEmpty
                  ? noDeviceFoundWidget()
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (BuildContext context, int index) {
                        BleDevice device = devices[index];
                        return InkWell(
                          onTap: () {
                            stopScanning();
                            onDeviceTap(device);
                          },
                          child: Card(
                            child: ListTile(
                                title: Text(
                                  "${device.name.isEmpty ? "N/A" : device.name} ( ${device.address} )",
                                ),
                                // trailing: Text(device.manufacturerData.toString()),
                                subtitle: Text(
                                    "Rssi : ${device.rssi} | AdvTpe : ${device.advType}")),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
    );
  }

  Widget kButton(String txt, Function() onTap, Color? buttonColor,
      {Color? textColor, IconData? buttonIcon}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
      child: Row(
        children: [
          Text(
            txt,
            style: TextStyle(fontSize: 20, color: textColor),
          ),
          Icon(buttonIcon)
        ],
      ),
    );
  }

  Widget kBButton(String label, String state, Function() onTap,
      {Color? buttonColor, Color? stateTextColor}) {
    return ElevatedButton(
      onPressed: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8), // Add spacing between label and state
          Text(
            state,
            style:
                TextStyle(fontSize: 20, color: stateTextColor, shadows: const [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(5.0, 5.0),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget noDeviceFoundWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isScanning
            ? const CircularProgressIndicator()
            : InkWell(
                onTap: () {
                  startScanning();
                },
                child: const Icon(
                  Icons.bluetooth,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
        const SizedBox(
          height: 10,
        ),
        Text(isScanning ? "Scanning Devices ... " : "Click to start scanning")
      ],
    );
  }
}
