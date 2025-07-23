import 'package:flutter/material.dart';
import 'package:new_revenue/models/transaction.dart'; // Ensure this path is correct
import 'package:new_revenue/services/firestore_services.dart'; // Import the new FirestoreService
import 'package:new_revenue/add_transaction.dart'; // Import your AddTransactionScreen
import 'package:new_revenue/dashboard_screen.dart'; // Import your DashboardScreen
import 'dart:async'; // For StreamSubscription

// --- 2. Your TransactionsScreen StatefulWidget ---
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

// --- 3. The State class where Firestore integration happens ---
class _TransactionsScreenState extends State<TransactionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Transaction>>? _transactionsSubscription;
  List<Transaction> _userTransactions = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndListenToTransactions();
  }

  Future<void> _initializeFirebaseAndListenToTransactions() async {
    try {
      await _firestoreService.initializeFirebase();
      _firestoreService.auth.authStateChanges().listen((user) {
        if (user != null) {
          setState(() {
            _currentUserId = user.uid;
          });
          _listenToTransactions();
        } else {
          // Handle cases where user is logged out or not authenticated
          setState(() {
            _currentUserId = null;
            _userTransactions = [];
            _isLoading = false;
          });
          _transactionsSubscription?.cancel();
        }
      });
    } catch (e) {
      print('Error initializing Firebase or signing in: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize app: $e')),
      );
    }
  }

  void _listenToTransactions() {
    _transactionsSubscription?.cancel(); // Cancel previous subscription if any
    if (_currentUserId != null) {
      // Ensure the stream is correctly typed here
      _transactionsSubscription =
          _firestoreService.getTransactionsStream().listen(
        (transactions) {
          setState(() {
            _userTransactions = transactions;
            _isLoading = false;
          });
        },
        onError: (error) {
          print('Error fetching transactions: $error');
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load transactions: $error')),
          );
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _transactionsSubscription
        ?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  // Function to navigate to the AddTransactionScreen
  void _navigateToAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddTransactionScreen(),
      ),
    );
  }

  // Function to navigate to the DashboardScreen
  void _navigateToDashboardScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Screen'),
        backgroundColor: Colors.deepPurple, // Added styling
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                _navigateToAddTransactionScreen, // Navigate to AddTransactionScreen
          ),
          // --- New: Button to navigate to DashboardScreen ---
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: _navigateToDashboardScreen,
            tooltip: 'View Dashboard',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display User ID for multi-user context
                if (_currentUserId != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'User ID: $_currentUserId',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: _userTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions added yet!',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _userTransactions.length,
                          itemBuilder: (ctx, index) {
                            final tx = _userTransactions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              elevation:
                                  4, // Increased elevation for better look
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12)), // Rounded corners
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28, // Slightly smaller avatar
                                  backgroundColor: tx.type == 'income'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  child: Icon(
                                    tx.type == 'income'
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: tx.type == 'income'
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                title: Text(
                                  tx.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${tx.category} (${tx.type.toUpperCase()}) - ${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Text(
                                  '\$${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tx.type == 'income'
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                // You can add more actions like delete here
                                // For example, a delete button:
                                onTap: () {
                                  _firestoreService.deleteTransaction(tx.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
