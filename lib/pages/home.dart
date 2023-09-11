import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey, // Add this line to assign the GlobalKey
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
              Icons.dashboard,
              size: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Dashboard'),
          ],
        ),
      ),

      drawer: const CustomDrawer(), // Use your custom drawer widget
      body: const Center(
        child: Text(
          'PodSwitch',
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
