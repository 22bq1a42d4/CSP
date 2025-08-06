// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'package:new_revenue/dashboard_screen.dart';
import 'package:new_revenue/transactions_screen.dart';
import 'package:new_revenue/suggestions_screen.dart';
import 'package:new_revenue/add_transaction.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Animate to the page when a tab is tapped
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const <Widget>[
          DashboardScreen(),
          TransactionsScreen(),
          SuggestionsScreen(),
        ],
      ),
      // This FAB is now global for all screens managed by MainScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTabItem(index: 0, icon: Icons.dashboard, text: 'Dashboard'),
              _buildTabItem(
                  index: 1, icon: Icons.list_alt, text: 'Transactions'),
              const SizedBox(width: 48), // The space for the FAB notch
              _buildTabItem(
                  index: 2, icon: Icons.lightbulb_outline, text: 'Suggestions'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build each navigation tab item
  Widget _buildTabItem(
      {required int index, required IconData icon, required String text}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.deepPurple : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(text, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
