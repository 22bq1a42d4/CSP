// lib/models/budget.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.userId,
  });

  // Factory constructor to create a Budget object from a Firestore DocumentSnapshot
  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Budget(
      id: doc.id,
      category: data['category'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String? ?? '',
    );
  }

  // Method to convert a Budget object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }
}
