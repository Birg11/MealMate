import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMealPlanDetails extends StatefulWidget {
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final List<String> pickupDays; // New field for pickup days

  CustomerMealPlanDetails({
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.pickupDays, // Include the new field in the constructor
  });

  @override
  _CustomerMealPlanDetailsState createState() => _CustomerMealPlanDetailsState();
}

class _CustomerMealPlanDetailsState extends State<CustomerMealPlanDetails> {
  bool isLoading = false; // State variable for loading

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Slider with Loading Indicator
              if (widget.images.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: widget.images.map((imageUrl) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(child: CircularProgressIndicator(color: Colors.white)),
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator(color: Colors.white));
                            },
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Center(child: Text("No images available", style: TextStyle(fontSize: 16, color: Colors.white70))),

              SizedBox(height: 20),

              // Meal Info Card (Glass Effect)
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.amberAccent),
                        SizedBox(width: 5),
                        Text('\$${widget.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.white),
                        SizedBox(width: 5),
                        Expanded(child: Text(widget.description, style: TextStyle(fontSize: 16, color: Colors.white70))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Pickup Days: ${widget.pickupDays.join(', ')}', // Display pickup days as a comma-separated string
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Customer Reviews
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 10),
                    _buildReview("John Doe", 5, "Delicious and worth the price!"),
                    _buildReview("Sarah Lee", 4, "Great meal, but could use more spice."),
                    // Add more reviews as needed
                  ],
                ),
              ),

              SizedBox(height: 60),
Center(
  child: ElevatedButton(
    onPressed: isLoading ? null : () async {
      bool confirm = await _showConfirmationDialog(context);
      if (!confirm) return;

      setState(() => isLoading = true); // Start loading
      try {
        await placeOrder(widget.name); // Corrected: Use widget.name
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      } finally {
        setState(() => isLoading = false); // Stop loading
      }
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.greenAccent, // Changed color for "Order Now"
      shadowColor: Colors.green.withOpacity(0.5),
      elevation: 10,
    ),
    child: isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              SizedBox(width: 10),
              Text("Processing...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          )
        : Text("Order Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
Future<bool> _showConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Confirm Order"),
      content: Text("Do you want to place this order?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Confirm")),
      ],
    ),
  ) ?? false;
}
Future<void> placeOrder(String mealName) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not logged in.");
  }

  // Fetch the user profile document using the user's UID as the document ID
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)  // Use uid (user's unique ID) as the document ID
      .get();

  if (!userDoc.exists) {
    // Handle case when user profile does not exist in Firestore
    throw Exception("User profile not found. Please complete your profile.");
  }

  // Fetch the user's name from Firestore
  String userName = userDoc.get('name');
  String orderId = "order_${DateTime.now().millisecondsSinceEpoch}";
  DateTime orderDate = DateTime.now();

  // Order data to save in Firestore
  Map<String, dynamic> orderData = {
    'orderId': orderId,
    'mealName': mealName,
    'status': 'pending',
    'orderDate': orderDate.toIso8601String(),
    'userId': user.uid,  // Including the user's UID in the order
    'userName': userName, // Including the user's name in the order
    'userEmail': user.email,  // Including the user's email in the order
  };

  // Save the order under the user's collection using their UID
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)  // Use uid (user's unique ID) as the document ID
      .collection('orders')
      .doc(orderId)
      .set(orderData);

  print("Order successfully placed for $userName with order ID: $orderId");
}


  // Glassmorphism Card Effect
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  // Customer Review Widget
  Widget _buildReview(String name, int rating, String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: Colors.white70),
            SizedBox(width: 5),
            Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        Row(
          children: List.generate(5, (index) => Icon(Icons.star, color: index < rating ? Colors.amberAccent : Colors.grey, size: 16)),
        ),
        SizedBox(height: 10),
        Text(comment, style: TextStyle(fontSize: 14, color: Colors.white70)),
        Divider(color: Colors.white24),
      ],
    );
  }

  // Function to handle user subscription
  // Future<void> subscribeUser() async {
  //   // Assume you have a way to get the current user's ID
  //   String userId = "currentUserId"; // Replace with actual user ID logic
  //   String subscriptionId = "subscription_${DateTime.now().millisecondsSinceEpoch}"; // Unique ID for the subscription
  //   String subscriptionType = "Monthly"; // Example type
  //   DateTime startDate = DateTime.now();
  //   DateTime endDate = startDate.add(Duration(days: 30)); // Example for a monthly subscription

  //   await FirebaseFirestore.instance.collection('subscriptions').doc(userId).set({
  //     'subscriptionId': subscriptionId,
  //     'status': 'active',
  //     'type': subscriptionType,
  //     'startDate': startDate,
  //     'endDate': endDate,
  //   });
  // }
}
