import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Calculationwiget extends StatefulWidget {
  const Calculationwiget({super.key});

  @override
  State<Calculationwiget> createState() => _CalculationwigetState();
}

class _CalculationwigetState extends State<Calculationwiget> {
  double dailyExpense = 0.0;
  double monthlyExpense = 0.0;
  double yearlyExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateExpenses(); // Calculate expenses on widget initialization
  }

  Future<void> _calculateExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Expenses')
            .get();

        double totalDaily = 0.0;
        double totalMonthly = 0.0;
        double totalYearly = 0.0;

        DateTime now = DateTime.now();
        String currentMonth = "${now.month}-${now.year}";
        String currentYear = "${now.year}";

        for (var doc in expensesSnapshot.docs) {
          Timestamp timestamp = doc['Date'];
          DateTime date = timestamp.toDate();
          double price = double.parse(doc['Price'].toString());

          if (isSameDay(date, now)) {
            totalDaily += price;
          }

          if (isSameMonth(date, now)) {
            totalMonthly += price;
          }

          if (isSameYear(date, now)) {
            totalYearly += price;
          }
        }

        setState(() {
          dailyExpense = totalDaily;
          monthlyExpense = totalMonthly;
          yearlyExpense = totalYearly;
        });
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  String formatExpense(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildExpenseContainer('Daily', formatExpense(dailyExpense)),
        buildExpenseContainer('Monthly', formatExpense(monthlyExpense)),
        buildExpenseContainer('Yearly', formatExpense(yearlyExpense)),
      ],
    );
  }

  Widget buildExpenseContainer(String title, String amount) {
    return Container(
      height: 85,
      width: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,style: TextStyle(color: Colors.green),),
          SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
