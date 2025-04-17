// import 'package:flutter/material.dart';
// import 'package:stripe_payment/stripe_payment.dart'; // Ensure you have the stripe_payment package in your pubspec.yaml

// class PaymentScreen extends StatefulWidget {
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final _cardController = TextEditingController();
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize Stripe with your publishable key
//     StripePayment.setOptions(StripeOptions(
//       publishableKey: "pk_live_51QFkIjR87s07GhjEo9nMBc9cZKTQwus60OmnoKU7n86IbLfzLsuIldugyJIGMDaaCL9nZM2H1WhpSZ5DXDfRrX1V00yGhOr6L6", // Replace with your actual key
//       merchantId: "Test", // Optional
//       androidPayMode: 'test', // Change to 'production' for live mode
//     ));
//   }

//   Future<void> _processPayment() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       // Create a Payment Method using card details
//       var card = CreditCard(
//         number: _cardController.text,
//         expMonth: 12, // You may want to get this from the user
//         expYear: 23,  // You may want to get this from the user
//         cvc: '123',   // You may want to get this from the user
//       );

//       // Create a payment method
//       var paymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: card));
      
//       // Send payment method to your backend for further processing
//       // TODO: Call your backend API to handle the payment

//       print("Payment Method created: ${paymentMethod.id}");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Successful')));
//     } catch (error) {
//       print("Error: $error");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed')));
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Payment')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _cardController,
//               decoration: InputDecoration(labelText: 'Card Number'),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loading ? null : _processPayment,
//               child: _loading
//                   ? CircularProgressIndicator()
//                   : Text('Pay Now'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
