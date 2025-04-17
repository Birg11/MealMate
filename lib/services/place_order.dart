// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> placeOrder(String mealName) async {
//   // Get the current user
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     throw Exception("User not logged in.");
//   }

//   // Fetch user's name from Firestore
//   DocumentSnapshot userDoc = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.email) // Assuming the user's name is stored under their email
//       .get();

//   if (!userDoc.exists) {
//     throw Exception("User profile not found.");
//   }

//   String userName = userDoc.get('name'); // Get the name from Firestore
//   String orderId = "order_${DateTime.now().millisecondsSinceEpoch}"; // Unique order ID
//   DateTime orderDate = DateTime.now();

//   // Order data
//   Map<String, dynamic> orderData = {
//     'orderId': orderId,
//     'mealName': mealName,
//     'status': 'pending',
//     'orderDate': orderDate.toIso8601String(),
//   };

//   // Save order under user's name
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userName) // Save under user's name
//       .collection('orders')
//       .doc(orderId)
//       .set(orderData);
// }
