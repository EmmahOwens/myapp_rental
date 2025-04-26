import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dpo_standard/dpo.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// `PaymentService` class provides functionalities to handle payment operations.
class PaymentService {
  /// The DPO Company Token obtained from the DPO portal.
  static final String companyToken = dotenv.env['DPO_COMPANY_TOKEN'] ?? '';

  /// Initiates the payment process using the DPO Standard API.
  ///
  /// This method handles the entire payment flow, including creating a payment
  /// request with DPO, launching the payment process in a web view, and
  /// handling the payment response.
  ///
  /// Parameters:
  ///   - [context]: The build context for UI interactions.
  ///   - [amount]: The payment amount.
  ///   - [currency]: The currency code for the payment.
  ///   - [paymentOptions]: The payment type options available for the payment
  Future<void> makePayment(
      BuildContext context, int amount, String currency, {required Map<String,PaymentOption> paymentOptions, required String currency, required int amount} ) async {
     String paymentType = paymentOptions.keys.first;
    try {
      // Ensure the company token is available.
      if (companyToken.isEmpty) {
        throw Exception('DPO Company Token is not set.');
      }
      final user = FirebaseAuth.instance.currentUser;
      if(user == null){
         throw Exception('User is not logged in.');
      }

      // Create a unique transaction reference.
      String transactionReference = DateTime.now().millisecondsSinceEpoch.toString();

      // Define the payment details.
      DpoPayment payment = DpoPayment(
        companyToken: companyToken,
        paymentAmount: amount.toDouble(),
        paymentCurrency: currency,
        paymentDescription: 'Rent Payment',
        paymentReference: transactionReference,
        customerEmail: user.email, // Placeholder, replace with actual customer email
        customerFirstName: "FirstName", // Placeholder, replace with actual customer first name
        customerLastName: "LastName", // Placeholder, replace with actual customer last name
      );

         paymentOptions.forEach((key, value) => payment.addPaymentOption(value, value));
      // Create a payment request using the payment details.
     DpoPaymentRequest request = DpoPaymentRequest(payment: payment);

      // Get the URL for the payment process.
      Uri url = await request.buildUrl();

      // Launch the payment process in a web view.
      DpoPaymentResponse response = await request.launch(url: url);
      

      // Handle the payment response.
      _processPaymentResponse(context, response,amount,paymentType);
    } catch (e) {
      // Handle exceptions during the payment process.
      _showErrorSnackBar(context, 'Payment Error: $e');
    }
  }

  /// Processes the DPO payment response and shows appropriate messages.
  ///
  /// This method determines whether the payment was successful based on the
  /// response and displays a corresponding message to the user.
  ///
  /// Parameters:
  ///   - [context]: The build context for UI interactions.
  ///   - [response]: The `DpoPaymentResponse` object received from the payment process.
    ///   - [amount]: The payment amount.
  ///   - [paymentType]: The type of payment (e.g., card, mobile money, bank transfer).
   void _processPaymentResponse(
      BuildContext context, DpoPaymentResponse response, int amount, String paymentType) async {
        if (response.paymentStatus == PaymentStatus.success) {
      // If the payment was successful, show a success message.
      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('payments').add({
          'userEmail': user?.email,
          'amount': amount,
          'date': DateTime.now(),
          'paymentMethod': paymentType,
          'receiptUrl':
              'dummy_receipt_url', // Placeholder, replace with actual receipt URL
        });

        print('Receipt added to Firestore');
      } catch (e) {
        print('Error adding receipt to Firestore: $e');
      }

      _showSuccessToast('Payment Successful!');
      _showSuccessSnackBar(context, 'Payment Successful!');
    } else {
      // If the payment was not successful, show an error message.
      _showErrorToast('Payment Failed: ${response.paymentStatus}');
      _showErrorSnackBar(context, 'Payment Failed: ${response.paymentStatus}');
    }
  }

  /// Shows a success message using FlutterToast.
  ///
  /// Parameters:
  ///   - [message]: The success message to display.
  static void _showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white);
  }

  /// Shows an error message using FlutterToast.
  ///
  /// Parameters:
  ///   - [message]: The error message to display.
   void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: 'Error: $message',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  /// Shows an error message using SnackBar.
  ///
  /// Parameters:
  ///   - [context]: The build context for UI interactions.
  ///   - [message]: The error message to display.
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}