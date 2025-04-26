import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../payment_service.dart'; 

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String messageText) async {
    final user = _auth.currentUser;
    if (user != null && messageText.trim().isNotEmpty) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] as String? ?? 'Unknown User';
      
      await _firestore.collection('messages').add({
        'senderId': user.uid,
        'senderName': userName,
        'message': messageText,
        'timestamp': Timestamp.now(),
      });      
      _messageController.clear();      
    }
  }

  @override
 Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { 
                  return const Center(child: Text('No messages yet.'));
                }
                final List<Map<String, dynamic>> messages = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                  })
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                   

                      final isCurrentUser =
                         message['senderId'] == _auth.currentUser?.uid;
                      final Timestamp timestamp = message['timestamp'];
                      final time = timestamp.toDate();
                      

                      final formattedTime = DateFormat('HH:mm').format(time);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isCurrentUser)
                                  Text(
                                    message['senderName'] as String? ?? 'Unknown',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.03),
                                  ),
                                Text(
                                  message['message'] as String? ?? '',
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                                      ),
                        ],
                      ),
                    );
                    },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                  Expanded(
                    child: Container(
                     padding: const EdgeInsets.only(left: 12),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send,size: 30,),
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  } 
}


class TenantDashboard extends StatelessWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Tenant Dashboard!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                
                 final paymentService = PaymentService();
                final paymentOptions = {
                  'card': PaymentOption.card,
                  'mobilemoney': PaymentOption.mobileMoney,
                  'banktransfer': PaymentOption.eft,
                }; 
                 paymentService.makePayment(
                  context,
                  amount: 800000,
                  currency: 'UGX', 
                  paymentOptions: {},
                );
              },
              child: const Text('Pay Rent'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              child: const Text('Chat with Landlord'),
            ),
          ],
        ),
      ),
    );
  }
}
