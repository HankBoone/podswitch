import 'dart:async';
import 'package:flutter/material.dart';
import 'package:podswitch/widgets/bluetooth.dart';
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
  StreamSubscription? bleStateStream;
  bool isScanning = false;
  String bleStatus = ""; // Define bleStatus
  String bleError = ""; // Define bleError
  @override
  void initState() {
    super.initState();
    Bluetooth().initialize();
    Bluetooth().updateBluetoothState(true);

    scanStream = WinBle.scanStream.listen((event) {
      setState(() {
        final index = Bluetooth()
            .devices
            .indexWhere((element) => element.address == event.address);
        if (index != -1) {
          final name = Bluetooth().devices[index].name;
          Bluetooth().devices[index] = event;
          if (event.name.isEmpty || event.name == 'N/A') {
            Bluetooth().devices[index].name = name;
          }
        } else {
          Bluetooth().devices.add(event);
        }
      });
    });

    bleStateStream = WinBle.bleState.listen((BleState state) {
      setState(() {
        Bluetooth().bleState = state;
        // Update bleStatus based on the Bluetooth state
        if (state == BleState.On) {
          bleStatus = "Bluetooth is On";
        } else {
          bleStatus = "Bluetooth is Off";
        }
      });
    });
  }

  @override
  void dispose() {
    scanStream?.cancel();
    bleStateStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getBluetoothTextColor() {
      return Bluetooth().bleState == BleState.On ? Colors.green : Colors.red;
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
            Bluetooth().bleState == BleState.On ? "On" : "Off",
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
                          Bluetooth().stopScanning();
                          setState(() {
                            isScanning = false;
                          });
                        },
                        Colors.red,
                        textColor: Colors.white,
                      )
                    : kButton(
                        "Start Scan",
                        () {
                          Bluetooth().startScanning();
                          setState(() {
                            isScanning = true;
                          });
                        },
                        Colors.green,
                        textColor: Colors.white,
                      ),
                kButton(
                    Bluetooth().bleState == BleState.On
                        ? "Turn off Bluetooth"
                        : "Turn on Bluetooth", () {
                  if (Bluetooth().bleState == BleState.On) {
                    WinBle.updateBluetoothState(false).then((state) {
                      setState(() {
                        Bluetooth().bleState = BleState.Off;
                      });
                    });
                  } else if (Bluetooth().bleState == BleState.Off) {
                    WinBle.updateBluetoothState(true).then((state) {
                      setState(() {
                        Bluetooth().bleState = BleState.On;
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
              child: Bluetooth().devices.isEmpty
                  ? noDeviceFoundWidget()
                  : ListView.builder(
                      itemCount: Bluetooth().devices.length,
                      itemBuilder: (BuildContext context, int index) {
                        BleDevice device = Bluetooth().devices[index];
                        return InkWell(
                          onTap: () {
                            Bluetooth().stopScanning();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceInfo(
                                  device: device,
                                ),
                              ),
                            );
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
                  Bluetooth().startScanning();
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
