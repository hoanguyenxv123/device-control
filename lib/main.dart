import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_control/screens/start/start_screen.dart';
import 'data/provider/user_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? lastDeviceId = await getLastConnectedDevice();

  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MyApp(lastDeviceId: lastDeviceId),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? lastDeviceId;

  const MyApp({super.key, this.lastDeviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Device',
      theme: ThemeData(fontFamily: 'Rubik'),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(lastDeviceId: lastDeviceId),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? Container(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final String? lastDeviceId;

  const AuthWrapper({super.key, this.lastDeviceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.data != null) {
          if (lastDeviceId != null && lastDeviceId!.isNotEmpty) {
            return const DashboardScreen();
          } else {
            // return  BluetoothControlScreen();
            return const DashboardScreen();
          }
        } else {
          return const StartScreen();
        }
      },
    );
  }
}

Future<String?> getLastConnectedDevice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('lastConnectedDevice');
}
