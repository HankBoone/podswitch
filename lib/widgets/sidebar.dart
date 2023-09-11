import 'package:flutter/material.dart';
import 'package:podswitch/pages/favorites.dart';

import '../pages/deviceselect.dart';
import '../pages/home.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                image: DecorationImage(
                    image: AssetImage("assets/images/PodSwitch.png"),
                    fit: BoxFit.cover)),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              // Navigate to the home page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth),
            title: const Text('Device Select'),
            onTap: () {
              // Navigate to the device selection page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DeviceSelect(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              // Navigate to the settings page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
          ),
          // Add more menu items as needed
        ],
      ),
    );
  }
}
