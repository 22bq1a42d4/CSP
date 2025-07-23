// home_screen.dart (now DashboardScreen)
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // IMPORTANT: Ensure this is fl_chart
import 'package:intl/intl.dart'; // For date formatting
import 'package:new_revenue/services/firestore_services.dart'; // Corrected import path
import 'package:new_revenue/models/transaction.dart'; // Import the actual Transaction model
import 'package:new_revenue/transactions_screen.dart'; // Import TransactionsScreen for navigation
import 'package:new_revenue/firebase_auth.dart'; // Import AuthScreen for logout navigation

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Use the actual FirestoreService
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    // No need to dispose _firestoreService here if it's a singleton or managed elsewhere.
    // If FirestoreService has a dispose method for its internal streams, call it if necessary.
    super.dispose();
  }

  // --- Logout function ---
  Future<void> _logout() async {
    try {
      await _firestoreService.auth.signOut();
      // After logging out, navigate back to the AuthScreen
      // We pushAndRemoveUntil to clear the navigation stack.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const AuthScreen()), // Navigate to AuthScreen
        (Route<dynamic> route) => false, // Remove all previous routes
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  // Function to navigate to the TransactionsScreen
  void _navigateToTransactionsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // --- Logout button ---
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, User!', // You can fetch user name from Firebase Auth
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 20),
            // Use StreamBuilder to check for transactions and display summary or prompt
            StreamBuilder<List<Transaction>>(
              stream: _firestoreService.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading data: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Display "Add Transaction" prompt if no data
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No transactions yet. Start by adding your first one!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _navigateToTransactionsScreen,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Transaction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // If there is data, build the summary cards and charts
                final transactions = snapshot.data!;
                final currentMonth = DateTime.now().month;
                final currentYear = DateTime.now().year;

                double totalIncome = 0;
                double totalExpenses = 0;

                for (var t in transactions) {
                  if (t.date.month == currentMonth &&
                      t.date.year == currentYear) {
                    if (t.type == 'income') {
                      totalIncome += t.amount;
                    } else {
                      totalExpenses += t.amount;
                    }
                  }
                }

                double netBalance = totalIncome - totalExpenses;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard(
                                'Income', totalIncome, Colors.green.shade400)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildSummaryCard('Expenses', totalExpenses,
                                Colors.red.shade400)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildSummaryCard(
                                'Balance', netBalance, Colors.blue.shade400)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Monthly Expenses Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildBarChart(),
                    const SizedBox(height: 30),
                    Text(
                      'Expenses by Category',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildPieChart(),
                    const SizedBox(
                        height: 80), // Added space below the pie chart
                  ],
                );
              },
            ),
          ],
        ),
      ),
      // --- Floating Action Button to add transactions ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToTransactionsScreen,
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Add a new transaction',
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Center the FAB
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder<List<Transaction>>(
        stream:
            _firestoreService.getTransactionsStream(), // Corrected method name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading bar chart data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data for bar chart.'));
          }

          final transactions = snapshot.data!;
          // Aggregate expenses by month for the last 6 months
          Map<int, double> monthlyExpenses = {};
          final now = DateTime.now();
          // Initialize for last 6 months (including current if applicable)
          for (int i = 0; i < 6; i++) {
            final date = DateTime(now.year, now.month - i, 1);
            // Use a unique key for month and year to avoid conflicts across years
            final monthYearKey = date.month + date.year * 100;
            monthlyExpenses[monthYearKey] = 0.0;
          }

          for (var t in transactions) {
            if (t.type == 'expense') {
              final monthYearKey = t.date.month + t.date.year * 100;
              if (monthlyExpenses.containsKey(monthYearKey)) {
                monthlyExpenses[monthYearKey] =
                    monthlyExpenses[monthYearKey]! + t.amount;
              }
            }
          }

          List<BarChartGroupData> barGroups = [];
          List<String> monthLabels = [];
          int x = 0;
          // Sort keys to ensure correct chronological order for the chart
          final sortedKeys = monthlyExpenses.keys.toList()
            ..sort((a, b) {
              final yearA = a ~/ 100;
              final monthA = a % 100;
              final yearB = b ~/ 100;
              final monthB = b % 100;
              if (yearA != yearB) return yearA.compareTo(yearB);
              return monthA.compareTo(monthB);
            });

          for (var key in sortedKeys) {
            final month = key % 100;
            final year = key ~/ 100;
            final monthName = DateFormat.MMM().format(DateTime(year, month));
            monthLabels.add(monthName);
            barGroups.add(
              BarChartGroupData(
                x: x,
                barRods: [
                  BarChartRodData(
                    toY: monthlyExpenses[key]!,
                    color: Colors.deepPurple.shade400,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: monthlyExpenses.values.isEmpty
                          ? 100
                          : monthlyExpenses.values
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2, // Max Y value
                      color: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            );
            x++;
          }

          return BarChart(
            BarChartData(
              barGroups: barGroups,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < monthLabels.length) {
                        // Prevent index out of bounds
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthLabels[value.toInt()],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        );
                      }
                      return Container(); // Return empty container if index is out of bounds
                    },
                    interval: 1, // Ensure all labels are shown
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // Corrected: Use tooltipBgColor for the background
                  //tooltipBackgroundColor: Colors.deepPurple,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(2)}',
                      // Text style for the tooltip item itself
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: StreamBuilder<List<Transaction>>(
        stream:
            _firestoreService.getTransactionsStream(), // Corrected method name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading pie chart data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data for pie chart.'));
          }

          final transactions = snapshot.data!;
          final currentMonthTransactions = transactions
              .where((t) =>
                  t.date.month == DateTime.now().month &&
                  t.date.year == DateTime.now().year &&
                  t.type == 'expense')
              .toList();

          if (currentMonthTransactions.isEmpty) {
            return const Center(
                child: Text('No expenses this month for pie chart.'));
          }

          Map<String, double> categoryExpenses = {};
          for (var t in currentMonthTransactions) {
            categoryExpenses.update(t.category, (value) => value + t.amount,
                ifAbsent: () => t.amount);
          }

          List<PieChartSectionData> sections = [];
          List<Color> pieColors = [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
            Colors.green.shade400,
            Colors.orange.shade400,
            Colors.red.shade400,
            Colors.teal.shade400,
            Colors.amber.shade400,
            Colors.cyan.shade400,
          ];
          int colorIndex = 0;

          categoryExpenses.forEach((category, amount) {
            sections.add(
              PieChartSectionData(
                color: pieColors[colorIndex % pieColors.length],
                value: amount,
                title: '\$${amount.toStringAsFixed(0)}',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                badgeWidget: _buildCategoryBadge(
                    category, pieColors[colorIndex % pieColors.length]),
                badgePositionPercentageOffset: 1.2,
              ),
            );
            colorIndex++;
          });

          return PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                // Handle touch events if needed
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadge(String category, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        category,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
