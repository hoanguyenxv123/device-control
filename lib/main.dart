import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard.dart';
import 'screens/bluetooth/bluetooth_control_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo gọi async trong main
  String? lastDeviceId = await getLastConnectedDevice();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp(lastDeviceId: lastDeviceId));
}

class MyApp extends StatelessWidget {
  final String? lastDeviceId;

  const MyApp({super.key, this.lastDeviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:Dashboard(),
      // home: lastDeviceId != null ? Dashboard() : BluetoothControlScreen(),
    );
  }
}

Future<String?> getLastConnectedDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('lastConnectedDevice');
}
