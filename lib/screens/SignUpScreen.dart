import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the login screen

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String errorMessage = "";
  String successMessage = "";
  bool _isLoading = false;  // Track loading state

  // Sign up method
Future<void> _signUpUser() async {
  setState(() {
    errorMessage = ""; // Reset error message
    successMessage = ""; // Reset success message
    _isLoading = true;  // Show loading indicator
  });

  try {
    // Check if email already exists
    final userDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text.trim())
        .get();

    if (userDocs.docs.isNotEmpty) {
      // Email already used
      setState(() {
        errorMessage = "Email is already used. Please try a different one.";
        _isLoading = false;  // Hide loading indicator
      });
      return;
    }

    // Create the user with Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Save user data to Firestore with the name as the document ID
    await FirebaseFirestore.instance.collection('users').doc(_nameController.text.trim()).set({
      'email': _emailController.text.trim(),
      'role': 'customer',  // Set the role as "customer"
      'name': _nameController.text.trim(),  // Save name under 'name'
    });

    // Show success message
    setState(() {
      successMessage = "Account created successfully!";
      _isLoading = false;  // Hide loading indicator
    });

    // Show a success snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Account created successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Redirect the user to login page after sign-up
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
    
  } catch (e) {
    setState(() {
      errorMessage = "Error during sign up. Please try again.";
      _isLoading = false;  // Hide loading indicator
    });
    print('Error during sign up: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create an Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Join our Food Truck Service now!",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      SizedBox(height: 30),
                      // Name Input
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Email Input
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Password Input
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUpUser, // Disable button if loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ) // Show loading circle
                              : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Success or Error Message
                      if (successMessage.isNotEmpty)
                        Text(
                          successMessage,
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      SizedBox(height: 16),
                      // Back to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          "Already have an account? Log In",
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
