// budget_screen.dart
import 'package:flutter/material.dart';
import 'package:new_revenue/services/firestore_services.dart';
import 'package:new_revenue/models/budget.dart'; // Import the Budget model
import 'package:intl/intl.dart'; // For date formatting

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Key for the form to manage validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  // Function to show the Add/Edit Budget dialog
  void _showBudgetDialog({Budget? budget}) {
    // Initialize controllers with existing budget data if editing
    if (budget != null) {
      _categoryController.text = budget.category;
      _amountController.text = budget.amount.toString();
      _selectedStartDate = budget.startDate;
      _selectedEndDate = budget.endDate;
    } else {
      // Clear for new budget
      _categoryController.clear();
      _amountController.clear();
      _selectedStartDate = null;
      _selectedEndDate = null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(budget == null ? 'Add New Budget' : 'Edit Budget',
            style: TextStyle(color: Colors.deepPurple)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon:
                        Icon(Icons.attach_money, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid positive number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: Text(
                    _selectedStartDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${DateFormat.yMMMd().format(_selectedStartDate!)}',
                    style: TextStyle(
                        color: _selectedStartDate == null
                            ? Colors.grey
                            : Colors.black),
                  ),
                  trailing:
                      Icon(Icons.calendar_today, color: Colors.deepPurple),
                  onTap: () => _selectDate(context, true),
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: Text(
                    _selectedEndDate == null
                        ? 'Select End Date'
                        : 'End Date: ${DateFormat.yMMMd().format(_selectedEndDate!)}',
                    style: TextStyle(
                        color: _selectedEndDate == null
                            ? Colors.grey
                            : Colors.black),
                  ),
                  trailing:
                      Icon(Icons.calendar_today, color: Colors.deepPurple),
                  onTap: () => _selectDate(context, false),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (_selectedStartDate == null || _selectedEndDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please select both start and end dates.')),
                  );
                  return;
                }
                if (_selectedStartDate!.isAfter(_selectedEndDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Start date cannot be after end date.')),
                  );
                  return;
                }

                final String category = _categoryController.text.trim();
                final double amount =
                    double.parse(_amountController.text.trim());
                final String currentUserId =
                    _firestoreService.userId ?? ''; // Get current user ID

                if (currentUserId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('User not logged in. Cannot save budget.')),
                  );
                  return;
                }

                if (budget == null) {
                  // Add new budget
                  final newBudget = Budget(
                    id: '', // Firestore will generate this
                    category: category,
                    amount: amount,
                    startDate: _selectedStartDate!,
                    endDate: _selectedEndDate!,
                    userId: currentUserId,
                  );
                  await _firestoreService.addBudget(newBudget);
                } else {
                  // Update existing budget
                  final updatedBudget = Budget(
                    id: budget.id,
                    category: category,
                    amount: amount,
                    startDate: _selectedStartDate!,
                    endDate: _selectedEndDate!,
                    userId: currentUserId,
                  );
                  await _firestoreService.updateBudget(updatedBudget);
                }
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(budget == null ? 'Add Budget' : 'Update Budget'),
          ),
        ],
      ),
    );
  }

  // Function to confirm deletion
  void _confirmDelete(String budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('Confirm Deletion', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteBudget(budgetId);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Budgets'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Budget>>(
        stream: _firestoreService.getBudgetsStream(), // Corrected method name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No budgets added yet. Tap the + button to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final budgets = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: \$${budget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Period: ${DateFormat.yMMMd().format(budget.startDate)} - ${DateFormat.yMMMd().format(budget.endDate)}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.edit, color: Colors.blue.shade700),
                              onPressed: () =>
                                  _showBudgetDialog(budget: budget),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red.shade700),
                              onPressed: () => _confirmDelete(budget.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Add New Budget',
        child: const Icon(Icons.add),
      ),
    );
  }
}
