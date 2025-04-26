import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/add_edit_tenant_screen.dart';
import '../screens/add_edit_expense_screen.dart';
import '../screens/login_screen.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({Key? key}) : super(key: key);

  @override
  _LandlordDashboardState createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _tenants = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;
    List<Map<String, dynamic>> _expenses = [];
    DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTenants();
    _filterExpensesByDate(_selectedDate);
    _calculateFinancials();
  }

  void _onDateChange(DateTime? newDate) {
    if (newDate != null) {
      setState(() => _selectedDate = newDate);
      _filterExpensesByDate(newDate);
    _calculateFinancials();
  }

  Future<void> _loadTenants() async {
    try {
      QuerySnapshot tenantsSnapshot =
          await _firestore.collection('tenants').get();
      setState(() {
        _tenants = tenantsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
      });
    } catch (e) {
      print('Error loading tenants: $e');
    }
  }

  Future<void> _calculateFinancials({DateTime? selectedDate}) async {
    double income = 0;
    double expenses = 0;
    DateTime date = selectedDate ?? _selectedDate;

    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0);

    try {
      QuerySnapshot paymentsSnapshot = await _firestore
          .collection('payments')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();
      paymentsSnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        income += data['amount'] ?? 0;
      });
    } catch (e) {
      print('Error loading payments: $e');
    }


    try {
      QuerySnapshot expensesSnapshot = await _firestore
          .collection('expenses')
          await _firestore.collection('expenses').get();

      expensesSnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        expenses += data['amount'] ?? 0;
      });
    } catch (e) {
      print('Error loading expenses: $e');
    }

      setState(() {
        _totalIncome = income;
        _totalExpenses = expenses;
      });
    }

    try {
      setState(() {
        _totalIncome = income;
        _totalExpenses = expenses;
      });    
    } catch (e) {
      print('Error calculating financials: $e');
    }
  }
    Future<void> _filterExpensesByDate(DateTime date) async {
    try {
      DateTime startOfMonth = DateTime(date.year, date.month, 1);
      DateTime endOfMonth = DateTime(date.year, date.month + 1, 0);

      QuerySnapshot expensesSnapshot = await _firestore
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      setState(() {
        _expenses = expensesSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
      });
      print('Error calculating financials: $e');
    }
  }

  void _addTenant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AddEditTenantScreen()),
    ).then((value) =>
        _loadTenants()); // Reload tenants after adding/editing one
  }

  void _editTenant(BuildContext context, Map<String, dynamic> tenant) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEditTenantScreen(tenant: tenant)),
    ).then((value) => _loadTenants()); // Reload tenants after adding/editing one
  }

  Future<void> _deleteTenant(
      BuildContext context, Map<String, dynamic> tenant) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this tenant?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
    if (confirmDelete) {
      await _firestore.collection('tenants').doc(tenant['id']).delete();
      _loadTenants();
    }
  }
  Future<void> _logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Logout'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
    if (confirmLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

    void _editExpense(BuildContext context, Map<String, dynamic> expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddEditExpenseScreen(expense: expense)),
    );
  }

   Future<void> _deleteExpense(BuildContext context, Map<String, dynamic> expense) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this expense?'),
              actions: <Widget>[
                 TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
                TextButton(child: const Text('Delete'), onPressed: () => Navigator.of(context).pop(true)),
              ],
            );
          },
        ) ?? false;
    if (confirmDelete) await _firestore.collection('expenses').doc(expense['id']).delete();
  }

  void _addExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(title: const Text('Landlord Dashboard')),
      body: Column(children: [
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select date to filter expenses: "),
                DropdownButton<DateTime>(
                    value: _selectedDate,
                    items: List<DropdownMenuItem<DateTime>>.generate(
                      12,
                      (index) => DropdownMenuItem<DateTime>(
                        value: DateTime(
                            DateTime.now().year, DateTime.now().month - index),
                        child: Text(DateFormat('MMMM yyyy').format(DateTime(
                            DateTime.now().year,
                            DateTime.now().month - index))),
                      ),
                    ),
                    onChanged: _onDateChange,
                  ),
              ],
            ),
          ),


       
      body: 
       Column(children: [
        Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Align(alignment: Alignment.topRight,child: IconButton(
              icon: const Icon(Icons.logout,size: 30,),
              onPressed: () => _logout(context),
            ),),
        ),
          Expanded(
            child:Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Income: UGX $_totalIncome',
                style: TextStyle(
                  fontSize: 18 * textScaleFactor, // Responsive text size
                ),
              ),
              Text(
                'Total Expenses: UGX $_totalExpenses',
                style: TextStyle(
                  fontSize: 18 * textScaleFactor, // Responsive text size
                ),
              ),
              SizedBox(height: screenWidth * 0.05), // Responsive spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _addTenant(context),
                    child: const Text('Add Tenant'),
                  ),
                  ElevatedButton(
                    onPressed: () => _addExpense(context),
                    child: const Text('Add Expense'),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.05),
             const Text('Tenants'),
              SizedBox(height: screenWidth * 0.05), // Responsive spacing
              ListView.builder(
                shrinkWrap: true, // Allow ListView to be inside a Column
                physics:
                    const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                itemCount: _tenants.length,
                itemBuilder: (context, index) {
                  final tenant = _tenants[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(tenant['name'] ?? 'No Name',
                            style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${tenant['email'] ?? 'No Email'}',
                                  style: TextStyle(
                                      fontSize: 14 * textScaleFactor)),
                              Text(
                                  'Rent Status: ${tenant['rentStatus'] ?? 'Unknown'}',
                                  style: TextStyle(
                                      fontSize: 14 * textScaleFactor)),
                              Text('Due Date: ${tenant['dueDate'] ?? 'N/A'}',
                                  style: TextStyle(
                                      fontSize: 14 * textScaleFactor)),
                            ],
                          ),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTenant(tenant)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTenant(tenant)),
                        ],

                        ),
                      ),
                    );
                  },
                )
              ,),),
            const Text('Expenses'),
             ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  final date = (expense['date'] as Timestamp?)?.toDate();
                  return Card(
                    child: ListTile(
                      title: Text(expense['description'] ?? 'No Description'),
                      subtitle: Text('Amount: ${expense['amount']} - Date: ${date.toString().substring(0,10)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editExpense(context, expense)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteExpense(context, expense)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
       ),
        ),
      ),
    );
  }
}}