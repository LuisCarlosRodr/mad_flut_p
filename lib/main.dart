import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'screens/splash_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';
import 'screens/map_screen.dart';
import 'login_screen.dart';
import 'weather_model.dart';
import 'firebase_options.dart'; // Asegúrate de importar las opciones de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter APP',
      home: const AuthWrapper(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        primaryColor: Colors.blueGrey,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const MainScreen(); // Usuario está logueado
          }
          return const LoginScreen(); // Usuario no está logueado
        }
        return const Center(child: CircularProgressIndicator()); // Esperando conexión
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const SplashScreen(),
    const SecondScreen(),
    const ThirdScreen(),
    const MapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Flutter App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor: Colors.blueGrey[50],
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(color: Colors.blueGrey[900]),
            selectedLabelTextStyle: TextStyle(color: Colors.blueGrey[900]),
            unselectedIconTheme: IconThemeData(color: Colors.blueGrey[600]),
            unselectedLabelTextStyle: TextStyle(color: Colors.blueGrey[600]),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home_filled),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search_rounded),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                selectedIcon: Icon(Icons.notifications_active),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map),
                selectedIcon: Icon(Icons.map),
                label: Text('Map'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: _screens.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}
