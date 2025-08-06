// lib/suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:new_revenue/services/firestore_services.dart';
import 'package:new_revenue/models/transaction.dart';

// A simple model for a suggestion
class Suggestion {
  final String title;
  final String description;
  final IconData icon;

  Suggestion(
      {required this.title, required this.description, required this.icon});
}

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  // This function analyzes transactions and returns a list of suggestions
  List<Suggestion> _generateSuggestions(List<Transaction> transactions) {
    final List<Suggestion> suggestions = [];

    // Analyzer 1: High Spending Category
    final expenseTransactions =
        transactions.where((t) => t.type == 'expense').toList();
    if (expenseTransactions.isNotEmpty) {
      Map<String, double> categorySpending = {};
      for (var tx in expenseTransactions) {
        categorySpending.update(tx.category, (value) => value + tx.amount,
            ifAbsent: () => tx.amount);
      }

      final sortedCategories = categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedCategories.isNotEmpty) {
        final topCategory = sortedCategories.first;
        suggestions.add(Suggestion(
          title: 'High Spending in "${topCategory.key}"',
          description:
              'You spent \$${topCategory.value.toStringAsFixed(2)} in this category. Consider reviewing these expenses to find potential savings.',
          icon: Icons.pie_chart_outline,
        ));
      }
    }

    // Analyzer 2: Income vs. Expense Ratio for the last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentTransactions =
        transactions.where((t) => t.date.isAfter(thirtyDaysAgo)).toList();
    final totalRecentIncome = recentTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
    final totalRecentExpenses = recentTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);

    if (totalRecentIncome > 0) {
      final ratio = totalRecentExpenses / totalRecentIncome;
      if (ratio > 0.8) {
        suggestions.add(Suggestion(
          title: 'High Expense Ratio',
          description:
              'Your expenses over the last 30 days have been more than 80% of your income. It might be a good time to create a budget.',
          icon: Icons.warning_amber_rounded,
        ));
      } else if (ratio < 0.5) {
        suggestions.add(Suggestion(
          title: 'Great Savings Rate!',
          description:
              'You are spending less than 50% of your income. Fantastic job! Consider investing the surplus to grow your wealth.',
          icon: Icons.trending_up,
        ));
      }
    }

    // Analyzer 3: Check for potential subscriptions
    final potentialSubscriptions = expenseTransactions
        .where((tx) =>
            tx.title.toLowerCase().contains('subscription') ||
            tx.title.toLowerCase().contains('monthly'))
        .toList();

    if (potentialSubscriptions.isNotEmpty) {
      suggestions.add(Suggestion(
        title: 'Review Your Subscriptions',
        description:
            'We noticed some transactions that might be recurring subscriptions. It\'s a good idea to review them periodically to ensure you still need them.',
        icon: Icons.subscriptions_outlined,
      ));
    }

    // Default message if no other specific suggestions are generated
    if (suggestions.isEmpty) {
      suggestions.add(Suggestion(
        title: 'Keep Up the Good Work!',
        description:
            'Your finances seem to be in good order. Continue tracking your transactions to stay on top of your financial goals.',
        icon: Icons.check_circle_outline,
      ));
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Suggestions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: firestoreService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Add some transactions to get personalized financial suggestions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          final suggestions = _generateSuggestions(snapshot.data!);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    leading: Icon(suggestion.icon,
                        color: Colors.deepPurple, size: 30),
                    title: Text(suggestion.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(suggestion.description),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
