// dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import 'package:new_revenue/services/firestore_services.dart';
import 'package:new_revenue/models/transaction.dart';
import 'package:new_revenue/transactions_screen.dart';
import 'package:new_revenue/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    super.dispose();
  }

  // --- Logout function ---
  Future<void> _logout() async {
    try {
      await _firestoreService.auth.signOut();
      // The AuthWrapper will handle navigation after logout.
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      // --- UPDATED: Removed the redundant auth-checking StreamBuilder ---
      // The AuthWrapper now handles routing, so this screen can assume the user is logged in.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // You can enhance this with the user's actual display name or email
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 20),
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
                    _buildFinancialSuggestions(totalIncome, totalExpenses),
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
                    const SizedBox(height: 80), // Space below the pie chart
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToTransactionsScreen,
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Add a new transaction',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Widget _buildFinancialSuggestions(double totalIncome, double totalExpenses) {
    String suggestion = '';
    if (totalIncome > 0 && totalExpenses > totalIncome * 0.7) {
      suggestion = 'Consider reducing expenses in non-essential categories.';
    } else if (totalIncome > 0 && totalExpenses > totalIncome * 0.5) {
      suggestion = 'Your spending is moderate. Good job!';
    } else {
      suggestion = 'Great savings! Consider investing your extra income.';
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.deepPurple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Tip',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
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
          stream: _firestoreService.getTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error loading bar chart data: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data for bar chart.'));
            }

            final transactions = snapshot.data!;
            Map<int, double> monthlyExpenses = {};
            final now = DateTime.now();

            for (int i = 0; i < 6; i++) {
              final date = DateTime(now.year, now.month - i, 1);
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

            final sortedKeys = monthlyExpenses.keys.toList()
              ..sort((a, b) {
                final yearA = a ~/ 100;
                final monthA = a % 100;
                final yearB = b ~/ 100;
                final monthB = b % 100;
                if (yearA != yearB) return yearA.compareTo(yearB);
                return monthA.compareTo(monthB);
              });

            List<BarChartGroupData> barGroups = [];
            List<String> monthLabels = [];
            int x = 0;

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
                                1.2,
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthLabels[value.toInt()],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          );
                        }
                        return Container();
                      },
                      interval: 1,
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(2)}',
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
      ),
    );
  }

  Widget _buildPieChart() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
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
          stream: _firestoreService.getTransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Error loading pie chart data: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data for pie chart.'));
            }

            final transactions = snapshot.data!;
            final currentMonthTransactions = transactions
                .where((t) =>
                    t.date.month == DateTime.now().month &&
                    t.date.year == DateTime.now().year)
                .toList();

            if (currentMonthTransactions.isEmpty) {
              return const Center(
                  child: Text('No transactions this month for pie chart.'));
            }

            Map<String, double> categoryExpenses = {};
            Map<String, double> categoryIncomes = {};

            for (var t in currentMonthTransactions) {
              if (t.type == 'expense') {
                categoryExpenses.update(t.category, (value) => value + t.amount,
                    ifAbsent: () => t.amount);
              } else if (t.type == 'income') {
                categoryIncomes.update(t.category, (value) => value + t.amount,
                    ifAbsent: () => t.amount);
              }
            }

            List<PieChartSectionData> sections = [];
            List<Color> expenseColors = [
              Colors.red.shade400,
              Colors.orange.shade400,
              Colors.teal.shade400,
              Colors.amber.shade400,
              Colors.cyan.shade400,
            ];
            List<Color> incomeColors = [
              Colors.green.shade400,
              Colors.blue.shade400,
              Colors.deepPurple.shade400,
              Colors.lightGreen.shade400,
              Colors.indigo.shade400,
            ];

            int expenseColorIndex = 0;
            categoryExpenses.forEach((category, amount) {
              sections.add(
                PieChartSectionData(
                  color:
                      expenseColors[expenseColorIndex % expenseColors.length],
                  value: amount,
                  title: '-\$${amount.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: _buildCategoryBadge('Expense: $category',
                      expenseColors[expenseColorIndex % expenseColors.length]),
                  badgePositionPercentageOffset: 1.2,
                ),
              );
              expenseColorIndex++;
            });

            int incomeColorIndex = 0;
            categoryIncomes.forEach((category, amount) {
              sections.add(
                PieChartSectionData(
                  color: incomeColors[incomeColorIndex % incomeColors.length],
                  value: amount,
                  title: '+\$${amount.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: _buildCategoryBadge('Income: $category',
                      incomeColors[incomeColorIndex % incomeColors.length]),
                  badgePositionPercentageOffset: 1.2,
                ),
              );
              incomeColorIndex++;
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
                  },
                ),
              ),
            );
          },
        ),
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
