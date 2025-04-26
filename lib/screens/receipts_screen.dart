import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({Key? key}) : super(key: key);

  Future<void> _downloadReceipt(String receiptUrl, String receiptName) async {
    // Placeholder for downloading the receipt
    // This should download the receipt from the URL and save it to the device
    // Then open the downloaded file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$receiptName';
      final file = File(filePath);
      // Simulate downloading
      await file.writeAsString('Receipt content from: $receiptUrl');

      OpenFilex.open(filePath);
    } catch (e) {
      print('Error downloading or opening file: $e');
    }
    print('Downloading receipt from: $receiptUrl');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Receipts')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('receipts')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No receipts available.'));
          }

          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  DateTime date = (data['date'] as Timestamp).toDate();
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Amount: UGX ${data['amount']?.toString() ?? 'N/A'}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${DateFormat('dd-MM-yyyy').format(date)}',
                          ),
                          Text('Method: ${data['paymentMethod'] ?? 'N/A'}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          _downloadReceipt(
                            data['receiptUrl'] ?? '',
                            'receipt_${document.id}.txt',
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
