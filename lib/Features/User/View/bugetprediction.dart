import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetPrediction extends StatefulWidget {
  const BudgetPrediction({super.key});

  @override
  State<BudgetPrediction> createState() => _BudgetPredictionState();
}

class _BudgetPredictionState extends State<BudgetPrediction> {
  final TextEditingController goalController = TextEditingController();
  Map<String, int>? suggestedBudget;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAndSendDataToModel();
  }

  Future<void> fetchAndSendDataToModel() async {
    setState(() {
      isLoading = true;
      suggestedBudget = null;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get user data from Firebase
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    // Retrieve monthly income
    int monthlyIncome = userDoc['totalIncome'];

    // Get the user's expenses collection
    QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Expenses')
        .get();

    Map<String, List<int>> monthlyExpenses = {};

    if (expensesSnapshot.docs.isNotEmpty) {
      // Group expenses by month
      for (var doc in expensesSnapshot.docs) {
        Timestamp timestamp = doc['Date'];
        DateTime date = timestamp.toDate();
        String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";

        if (!monthlyExpenses.containsKey(month)) {
          monthlyExpenses[month] = List<int>.filled(9, 0);
        }

        String categoryId = doc['CategoryId'];
        int amount = (doc['Price'] as num).toInt();

        // Fetch category name using CategoryId
        DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
            .collection('Categories')
            .doc(categoryId)
            .get();

        String categoryName = categoryDoc['Name'];

        // Assign expenses to the correct index based on category name
        switch (categoryName) {
          case 'Utilities':
            monthlyExpenses[month]![0] += amount;
            break;
          case 'Food':
            monthlyExpenses[month]![1] += amount;
            break;
          case 'Transportation':
            monthlyExpenses[month]![2] += amount;
            break;
          case 'Healthcare':
            monthlyExpenses[month]![3] += amount;
            break;
          case 'Personal Care':
            monthlyExpenses[month]![4] += amount;
            break;
          case 'Entertainment':
            monthlyExpenses[month]![5] += amount;
            break;
          case 'Education':
            monthlyExpenses[month]![6] += amount;
            break;
          case 'Savings':
            monthlyExpenses[month]![7] += amount;
            break;
          case 'Others':
            monthlyExpenses[month]![8] += amount;
            break;
          default:
            break;
        }
      }
    }

    List<List<int>> monthlyData = [];
    List<String> sortedMonths = monthlyExpenses.keys.toList()..sort();

    // Ensure we have exactly 3 months of data
    if (sortedMonths.length > 3) {
      sortedMonths = sortedMonths.sublist(sortedMonths.length - 3);
    } else if (sortedMonths.length < 3) {
      // Fill missing months with zeros if less than 3 months
      DateTime now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        String month = "${now.year}-${(now.month - i).toString().padLeft(2, '0')}";
        if (!monthlyExpenses.containsKey(month)) {
          monthlyExpenses[month] = List<int>.filled(9, 0);
        }
      }
      sortedMonths = monthlyExpenses.keys.toList()..sort();
    }

    // Prepare data for the model
    for (String month in sortedMonths) {
      monthlyData.add([monthlyIncome] + monthlyExpenses[month]!);
    }

    // Ensure exactly 3 months of data
    while (monthlyData.length < 3) {
      monthlyData.add([monthlyIncome] + List<int>.filled(9, 0));
    }

    // Create the data object for the API request
    Map<String, dynamic> data = {
      "Monthly Income": monthlyIncome,
      "Utilities_M1": monthlyData[0][1],
      "Food_M1": monthlyData[0][2],
      "Transportation_M1": monthlyData[0][3],
      "Healthcare_M1": monthlyData[0][4],
      "Personal Care_M1": monthlyData[0][5],
      "Entertainment_M1": monthlyData[0][6],
      "Education_M1": monthlyData[0][7],
      "Savings_M1": monthlyData[0][8],
      "Others_M1": monthlyData[0][9],

      "Utilities_M2": monthlyData[1][1],
      "Food_M2": monthlyData[1][2],
      "Transportation_M2": monthlyData[1][3],
      "Healthcare_M2": monthlyData[1][4],
      "Personal Care_M2": monthlyData[1][5],
      "Entertainment_M2": monthlyData[1][6],
      "Education_M2": monthlyData[1][7],
      "Savings_M2": monthlyData[1][8],
      "Others_M2": monthlyData[1][9],

      "Utilities_M3": monthlyData[2][1],
      "Food_M3": monthlyData[2][2],
      "Transportation_M3": monthlyData[2][3],
      "Healthcare_M3": monthlyData[2][4],
      "Personal Care_M3": monthlyData[2][5],
      "Entertainment_M3": monthlyData[2][6],
      "Education_M3": monthlyData[2][7],
      "Savings_M3": monthlyData[2][8],
      "Others_M3": monthlyData[2][9],
    };

    // Send data to Flask API
    try {
      final response = await http.post(
        Uri.parse('https://d1cd-223-123-97-182.ngrok-free.app/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        Map<String, dynamic> result = jsonDecode(response.body);
        Map<String, double> rawBudget = Map<String, double>.from(result);

        // Convert the budget to integer and round off decimals
        setState(() {
          suggestedBudget = rawBudget.map((key, value) => MapEntry(key, value.round()));
        });
      } else {
        setState(() {
          suggestedBudget = {"Error": response.statusCode};
        });
      }
    } catch (e) {
      setState(() {
        suggestedBudget = {"Error": -1};  // Using -1 as a sentinel value for errors
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),

            if (isLoading)
              Center(child: CircularProgressIndicator()),
            if (suggestedBudget != null)
              Expanded(
                child: ListView.builder(
                  itemCount: suggestedBudget!.length,
                  itemBuilder: (context, index) {
                    String category = suggestedBudget!.keys.elementAt(index);
                    int amount = suggestedBudget!.values.elementAt(index);

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${amount.toString()}",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
