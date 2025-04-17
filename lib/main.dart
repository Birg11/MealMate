import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/food_truck_dashboard.dart';
import 'customer/customer_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Truck Subscription',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),  // Initial screen
      routes: {
        '/ownerDashboard': (context) => FoodTruckDashboard(),
        '/customerDashboard': (context) => CustomerDashboard(),
      },
    );
  }
}
