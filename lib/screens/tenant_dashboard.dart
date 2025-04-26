import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../screens/chat_screen.dart';
import '../payment_service.dart';
import '../screens/receipts_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/edit_user_data_screen.dart';

import '../screens/login_screen.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

Future<void> _signOut(BuildContext context) async {
  bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: <Widget>[
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false)),
                TextButton(
                    child: const Text('Logout'),
                    onPressed: () => Navigator.of(context).pop(true)),
              ],
            );
          }) ??
      false;
  if (confirmLogout) {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

class _TenantDashboardState extends State<TenantDashboard> {
  String _selectedPaymentOption = 'card'; // Default payment option

  final List<String> _paymentOptions = [
    'card',
    'mobile_money',
    'bank_transfer'
  ];
  List<Map<String, dynamic>> _receipts = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

           return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payments')
                .where('userEmail', isEqualTo: user?.email)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> receiptSnapshot) {
              if (receiptSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (receiptSnapshot.hasData &&
                  receiptSnapshot.data!.docs.isNotEmpty) {
                _receipts = receiptSnapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
              }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${data['name']}',
                    style: TextStyle(
                        fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'Email: ${data['email']}',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'Due Date: ${data['dueDate'] ?? 'Not set'}',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'Rent Status: ${data['rentStatus'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _selectedPaymentOption,
                        items: _paymentOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {_selectedPaymentOption = newValue!;});
                        },
                      ),
                    ],
                  ),
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          PaymentService.makePayment(
                            context,
                            amount: 1000,
                            currency: 'UGX',
                            paymentType: _selectedPaymentOption,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenWidth * 0.03),
                        ),
                        child: Text(
                          'Pay Rent',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenWidth * 0.03),
                        ),
                        child: Text(
                          'Open Chat',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Text(
                    'Rent History',
                    style: TextStyle(
                        fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                   _receipts.isEmpty
                      ? const Center(child: Text('No receipts available'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _receipts.length,
                          itemBuilder: (context, index) {
                            final receipt = _receipts[index];
                            final date = (receipt['timestamp']
                                    as Timestamp)
                                .toDate();
                            final formattedDate = DateFormat('dd-MM-yyyy').format(date);

                            return ListTile(
                              title: Text(
                                'Payment - $formattedDate',
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                              subtitle: Text(
                                  'Amount: UGX ${receipt['amount']} - Method: ${receipt['paymentType']}',
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.035)),
                            );
                          },
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Center(
                    child: ElevatedButton(
                       onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditUserDataScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
                      ),
                      child: Text('Edit Profile', style: TextStyle(fontSize: screenWidth * 0.04),),
                    ),
                     child: ElevatedButton(
                      onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ReceiptsScreen()),
                          );                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
                      ),
                      child: Text('View/Download Receipts', style: TextStyle(fontSize: screenWidth * 0.04),),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
                      ),
                      child: Text('Change Password', style: TextStyle(fontSize: screenWidth * 0.04),),
                    ),
                ],
              ),
            ),
          );
             }
           );
        },
      ),
    );
  }

  void _showReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receipts'),
          content: const Text('Here you can view and download payment receipts.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}