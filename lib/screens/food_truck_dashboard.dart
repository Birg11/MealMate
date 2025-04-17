import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:mealmate/models/meal_plan.dart';

class FoodTruckDashboard extends StatefulWidget {
  @override
  _FoodTruckDashboardState createState() => _FoodTruckDashboardState();
}

class _FoodTruckDashboardState extends State<FoodTruckDashboard> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  List<File> _imageFiles = [];
  List<String> _selectedDays = [];
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var imageFile in _imageFiles) {
      try {
        String fileName = "mealPlanImages/${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    }
    return imageUrls;
  }

  Future<void> addMealPlan() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedDays.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    List<String> imageUrls = await _uploadImages();

    try {
      await _firestore.collection('mealPlans').doc(_nameController.text).set({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'pickupDays': _selectedDays,
        'images': imageUrls,
        'description': _descriptionController.text,
      });

      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal Plan added successfully!')));
    } catch (e) {
      print('Error adding meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding meal plan: $e')));
    }
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() {
      _imageFiles = [];
      _selectedDays.clear();
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      title: Text(
        'Food Truck Dashboard',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.orangeAccent,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_nameController, 'Meal Name', Icons.fastfood),
          _buildTextField(_priceController, 'Price', Icons.attach_money),
          _buildPickupDaysSelector(),
          _buildTextField(_descriptionController, 'Description', Icons.description),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Align buttons evenly
            children: [
              Expanded(child: _buildButton('Select Images', _pickImages, Icons.image)),
              SizedBox(width: 10), // Add some spacing between the buttons
              Expanded(child: _buildButton('Add Meal Plan', addMealPlan, Icons.add_box)),
            ],
          ),
          SizedBox(height: 15),
          if (_imageFiles.isNotEmpty) _buildImagePreview(),
          SizedBox(height: 20),
          Text('Meal Plans', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildMealPlansList(),
        ],
      ),
    ),
  );
}


  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orangeAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildPickupDaysSelector() {
    return Wrap(
      spacing: 8.0,
      children: _daysOfWeek.map((day) {
        final isSelected = _selectedDays.contains(day);
        return FilterChip(
          label: Text(day),
          selected: isSelected,
          selectedColor: Colors.orangeAccent,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(day);
              } else {
                _selectedDays.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, IconData icon) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(text, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _imageFiles.map((file) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              file,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
        )).toList(),
      ),
    );
  }

  // This widget should be implemented to display existing meal plans
Widget _buildMealPlansList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('mealPlans').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No meal plans available.'));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          var mealPlan = snapshot.data!.docs[index];

          return InkWell(
            onTap: () {
              // Navigate to details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealPlanDetails(mealPlan: mealPlan, name: null, price: null, description: null, images: [],),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: mealPlan['images'].isNotEmpty
                    ? Image.network(mealPlan['images'][0], width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.fastfood, size: 50),
                title: Text(mealPlan['name'] ?? 'Unnamed Meal', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${mealPlan['price']?.toString() ?? '0.00'}'),
              ),
            ),
          );
        },
      );
    },
  );
}

}