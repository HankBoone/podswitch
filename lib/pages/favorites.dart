import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:podswitch/database/models/favorites_db.dart';
import 'package:podswitch/pages/deviceinfo.dart';
import 'package:podswitch/widgets/sidebar.dart';
import 'package:win_ble/win_ble.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final favoritesDb = FavoritesDB();

  List<BleDevice> devices = <BleDevice>[];
  fetchFavorites() async {
    final favorites = await favoritesDb.fetchAll();
    if (kDebugMode) {
      print(favorites);
    }
    setState(() {
      devices = favorites;
    });
  }

  void initialize() async {
    fetchFavorites();
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void removeFromFavorites(BleDevice device) async {
    // Fetch the favorite by address to get its ID
    final favorite = await favoritesDb.fetchByAddress(address: device.address);

    // Delete the favorite by its ID
    await favoritesDb.delete(id: favorite.id);

    // Reload the list of favorite devices
    fetchFavorites();
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.favorite,
              size: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Favorites'),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
      body: devices.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No favorite devices',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Please add one from the device info screen',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    onPressed: () {
                      // Remove the device from favorites when the button is tapped
                      removeFromFavorites(device);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DeviceInfo(device: devices[index]),
                        ),
                      );
                    });
                  },
                );
              },
            ),
    );
  }
}
