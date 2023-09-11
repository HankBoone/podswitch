import 'dart:async';
import 'package:flutter/material.dart';
import 'package:podswitch/database/models/favorites_db.dart';
import 'package:podswitch/widgets/microphone.dart';
import 'package:podswitch/widgets/speakers.dart';
import 'package:win_ble/win_ble.dart';
import '../widgets/sidebar.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class DeviceInfo extends StatefulWidget {
  final BleDevice device;
  const DeviceInfo({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceInfo> createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  late BleDevice device;
  final favoritesDb = FavoritesDB();
  TextEditingController serviceTxt = TextEditingController();
  TextEditingController characteristicTxt = TextEditingController();
  TextEditingController uint8DataTxt = TextEditingController();
  bool connected = false;
  List<String> services = [];
  List<BleCharacteristic> characteristics = [];
  String result = "";
  String error = "none";
  List<BleDevice> devices = <BleDevice>[];
  final _snackbarDuration = const Duration(milliseconds: 700);

  bool speakerisMuted = false;

  fetchFavorites() async {
    final favorites = await favoritesDb.fetchAll();
    print(favorites);
    setState(() {
      devices = favorites;
    });
  }

  inDevices({required String address}) {
    for (var device in devices) {
      if (device.address == address) {
        return true;
      }
    }
    return false;
  }

  void showSuccess(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.green,
          duration: _snackbarDuration));

  void showError(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.red,
          duration: _snackbarDuration));

  void showNotification(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.blue,
          duration: _snackbarDuration));

  connect(String address) async {
    try {
      await WinBle.connect(address);
      showSuccess("Connected");
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  canPair(address) async {
    bool canPair = await WinBle.canPair(address);
    showNotification("CanPair : $canPair");
  }

  isPaired(address) async {
    bool isPaired = await WinBle.isPaired(address);
    showNotification("isPaired : $isPaired");
  }

  pair(String address) async {
    try {
      await WinBle.pair(address);
      showSuccess("Paired Successfully");
    } catch (e) {
      showError("PairError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  unPair(String address) async {
    try {
      await WinBle.unPair(address);
      showSuccess("UnPaired Successfully");
    } catch (e) {
      showError("UnPairError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  disconnect(address) async {
    try {
      await WinBle.disconnect(address);
      showSuccess("Disconnected");
    } catch (e) {
      if (!mounted) return;
      showError(e.toString());
    }
  }

  addFavorite(BleDevice device) {
    if (!inDevices(address: device.address)) {
      print(device.toJson());

      final List<String> serviceUuids =
          device.serviceUuids.map((dynamic uuid) => uuid.toString()).toList();

      favoritesDb.create(
        address: device.address,
        rssi: device.rssi.toString(),
        timestamp: device.timestamp,
        advType: device.advType,
        name: device.name,
        serviceUuids: serviceUuids, // Pass the converted list of strings
        manufacturerData:
            device.manufacturerData, // Pass manufacturerData directly
      );
      setState(() {
        fetchFavorites();
      });
      showNotification("Added to Favorites!");
    }
  }

  Future<void> removeFavorite(BleDevice device) async {
    final address = device.address;

    try {
      final favorite = await favoritesDb.fetchByAddress(address: address);

      await favoritesDb.delete(id: favorite.id);
      setState(() {
        fetchFavorites();
      });
      showNotification("Removed from Favorites!");
    } catch (e) {
      showError("Error removing from favorites: $e");
    }
  }

  StreamSubscription? _connectionStream;
  StreamSubscription? _characteristicValueStream;

  @override
  void initState() {
    device = widget.device;
    // subscribe to connection events
    _connectionStream =
        WinBle.connectionStreamOf(device.address).listen((event) {
      setState(() {
        connected = event;
      });
    });

    _characteristicValueStream =
        WinBle.characteristicValueStream.listen((event) {
      print("CharValue : $event");
    });

    fetchFavorites();
    FlutterVolumeController.getMute().then((value) => speakerisMuted = value!);
    super.initState();
  }

  @override
  void dispose() {
    try {
      // Cancel stream subscriptions
      _connectionStream?.cancel();
      _characteristicValueStream?.cancel();

      // Disconnect from the Bluetooth device if it's connected
      if (connected) {
        disconnect(device.address);
        print('Disconnected from ${device.name}');
      }
    } catch (e) {
      print('Error during dispose: $e');
    } finally {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open the drawer using the GlobalKey
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Text(widget.device.name),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(connected ? "Connected" : "Disconnected"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.circle,
                  color: connected ? Colors.green : Colors.red,
                ),
              )
            ],
          )
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Buttons
            const SizedBox(
              height: 10,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                connected
                    ? kButton("Disconnect", () {
                        disconnect(device.address);
                      })
                    : kButton("Connect", () {
                        connect(device.address);
                      }),
                Row(
                  children: [
                    connected
                        ? !inDevices(address: device.address)
                            ? IconButton(
                                onPressed: () {
                                  addFavorite(device);
                                },
                                icon:
                                    const Icon(Icons.favorite_border_outlined),
                              )
                            : Builder(
                                builder: (BuildContext context) {
                                  return Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          removeFavorite(device);
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const Text('Favorite')
                                    ],
                                  );
                                },
                              )
                        : const SizedBox(),
                  ],
                )
              ],
            ),
            const Divider(),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                kButton("Pair", () {
                  pair(device.address);
                }, enabled: connected),
                kButton("UnPair", () {
                  unPair(device.address);
                }, enabled: connected),
              ],
            ),
            // Service List

            kHeadingText(result, shiftLeft: true),

            const SizedBox(height: 10),
            kHeadingText("Error : $error", shiftLeft: true),
            const SizedBox(
              height: 20,
            ),
            kHeadingText("Services", shiftLeft: true),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SpeakersWidget(),
                MicrophoneWidget(),
              ],
            )
          ],
        ),
      ),
    );
  }

  kButton(String txt, onTap, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        child: Text(
          txt,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  kHeadingText(String title, {bool shiftLeft = false}) {
    return Column(
      crossAxisAlignment:
          shiftLeft ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(title),
        ),
        const Divider(),
      ],
    );
  }
}
