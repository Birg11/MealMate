
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MealPlanDetails extends StatelessWidget {
  final QueryDocumentSnapshot mealPlan;

  MealPlanDetails({required this.mealPlan, required name, required price, required description, required List<String> images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mealPlan['name']),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Images
            mealPlan['images'].isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mealPlan['images'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(mealPlan['images'][index], width: 200, height: 200, fit: BoxFit.cover),
                        );
                      },
                    ),
                  )
                : Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey)),

            SizedBox(height: 20),

            Text(mealPlan['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Text('Price: \$${mealPlan['price']}', style: TextStyle(fontSize: 18, color: Colors.green)),
            SizedBox(height: 10),

            Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(mealPlan['description'], style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            Text('Pickup Days:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: List.generate(
                (mealPlan['pickupDays'] as List).length,
                (index) => Chip(
                  label: Text(mealPlan['pickupDays'][index]),
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
