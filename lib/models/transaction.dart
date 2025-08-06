// lib/models/transaction.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String category; // e.g., 'Food', 'Transport', 'Salary'
  final String userId; // Added userId to link transactions to users

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.userId,
  });

  // Factory constructor to create a Transaction object from a Firestore DocumentSnapshot
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    // Safely get data as Map<String, dynamic> or an empty map if null
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Transaction(
      id: doc.id,
      title: data['title'] as String? ?? '', // Safely cast to String
      amount: (data['amount'] as num?)?.toDouble() ??
          0.0, // Safely cast to num then to double
      date: (data['date'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Safely cast to Timestamp then to DateTime
      type: data['type'] as String? ?? 'expense', // Safely cast to String
      category: data['category'] as String? ??
          'Uncategorized', // Safely cast to String
      userId: data['userId'] as String? ?? '', // Safely cast to String
    );
  }

  // Method to convert a Transaction object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date':
          Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      'type': type,
      'category': category,
      'userId': userId, // Include userId when saving to Firestore
    };
  }
}
