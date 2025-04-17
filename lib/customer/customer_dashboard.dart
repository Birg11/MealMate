import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mealmate/customer/customer_meal.dart';

class CustomerDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hey customer..'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('mealPlans').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No meal plans available.'));
          }

          var plans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              var mealPlan = plans[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerMealPlanDetails(
                        name: mealPlan['name'],
                        price: mealPlan['price'],
                        description: mealPlan['description'],
                        images: List<String>.from(mealPlan['images']),
                        pickupDays: List<String>.from(mealPlan['pickupDays'] ?? []),
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        mealPlan['images'].isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  mealPlan['images'][0],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.fastfood, size: 70, color: Colors.grey),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealPlan['name'] ?? 'Unnamed Meal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${mealPlan['price']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.teal),
                          onPressed: () {
                            placeOrder(mealPlan['name'], mealPlan['price']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    floatingActionButton: FloatingActionButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return ListTile(
                title: Text(order['mealName']),
                subtitle: Text("\$${order['price'].toStringAsFixed(2)}"),
              );
            },
          );
        },
      ),
    );
  },
  child: Icon(Icons.shopping_cart), // Cart icon
),

    );
  }

  // Function to place an order
Future<void> placeOrder(String mealName, double price) async {
  try {
    await FirebaseFirestore.instance.collection('orders').add({
      'mealName': mealName,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(), // Sort by time
    });
    print('Order saved successfully');
  } catch (e) {
    print('Error saving order: $e');
  }
}


  // Function to show orders in a bottom sheet
  void _showOrders(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('orders').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No orders placed yet.'));
            }

            var orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];

                return ListTile(
                  leading: Icon(Icons.fastfood, color: Colors.teal),
                  title: Text(order['name']),
                  subtitle: Text('\$${order['price'].toStringAsFixed(2)}'),
                  trailing: Text(
                    '${order['timestamp'].toDate()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
