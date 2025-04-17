import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mealmate/screens/SignUpScreen.dart';
import '../customer/customer_dashboard.dart';
import 'food_truck_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String errorMessage = "";

Future<void> _loginUser() async {
  setState(() {
    _isLoading = true;
    errorMessage = "";
  });

  try {
    // Authenticate user with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Retrieve user info from Firestore using email
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text.trim())
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      setState(() {
        errorMessage = "User not found in Firestore. Please sign up.";
        _isLoading = false;
      });
      return;
    }

    // Extract user name (which is used as the document ID in Firestore)
    String userName = userQuery.docs.first['name'];

    // Fetch the user's document using the name field
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userName)
        .get();

    if (userDoc.exists) {
      String role = userDoc['role'];

      if (role == "owner") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FoodTruckDashboard()),
        );
      } else if (role == "customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerDashboard()),
        );
      } else {
        setState(() {
          errorMessage = "Invalid role, contact support.";
        });
      }
    } else {
      setState(() {
        errorMessage = "User not found in Firestore. Please sign up.";
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Invalid email or password. Please try again.";
    });
  }

  setState(() {
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Log in to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Error Message
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),

                    SizedBox(height: 20),

                    // Login Button
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                    SizedBox(height: 20),

                    // Sign Up Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
