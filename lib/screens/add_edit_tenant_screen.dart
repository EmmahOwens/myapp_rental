import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditTenantScreen extends StatefulWidget {
  final Map<String, dynamic>? tenant;

  const AddEditTenantScreen({Key? key, this.tenant}) : super(key: key);

  @override
  _AddEditTenantScreenState createState() => _AddEditTenantScreenState();
}

class _AddEditTenantScreenState extends State<AddEditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rentStatusController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _nameController.text = widget.tenant!['name'] ?? '';
      _emailController.text = widget.tenant!['email'] ?? '';
      _rentStatusController.text = widget.tenant!['rentStatus'] ?? '';
      _dueDateController.text = widget.tenant!['dueDate'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rentStatusController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _saveTenant() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> tenantData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'rentStatus': _rentStatusController.text,
          'dueDate': _dueDateController.text,
        };

        if (widget.tenant == null) {
          await FirebaseFirestore.instance.collection('tenants').add(tenantData);
        } else {
          await FirebaseFirestore.instance
              .collection('tenants')
              .doc(widget.tenant!['id'])
              .update(tenantData);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving tenant: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenant == null ? 'Add Tenant' : 'Edit Tenant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _rentStatusController,
                decoration: const InputDecoration(labelText: 'Rent Status'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter rent status'
                    : null,
              ),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a due date'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTenant,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}