import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:personal_cash_flow_navigator/Features/User/View/Scraping.dart';

class BudgetSuggestionScreen extends StatefulWidget {
  @override
  _BudgetSuggestionScreenState createState() => _BudgetSuggestionScreenState();
}

class _BudgetSuggestionScreenState extends State<BudgetSuggestionScreen> {
  final TextEditingController goalController = TextEditingController();
  Map<String, int>? suggestedBudget;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
   // _fetchHateSpeechUrl();


  }


  Future<void> _fetchHateSpeechUrl() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Servers').doc('JvSHydQu7hBYg41DaJrb').get();
      setState(() {
        _facedetectionUrl = snapshot['Model'];
        print(_facedetectionUrl+"hereeee");
      });
      print('Hate Speech URL: $_facedetectionUrl');
    } catch (e) {
      print('Error fetching URL: $e');
    }
  }
  String _facedetectionUrl = '';


  Future<void> fetchAndSendDataToModel(int goal) async {
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

    List<List<dynamic>> previousData = [];

    if (monthlyExpenses.isNotEmpty) {
      // Prepare data for the model
      for (var entry in monthlyExpenses.entries) {
        previousData.add([monthlyIncome] + entry.value);
      }
    }

    // Create the data object for the API request
    Map<String, dynamic> data = {
      "monthly_income": monthlyIncome,
      "goal": goal,
      if (previousData.isNotEmpty) "previous_data": previousData,
    };

    // Send data to Flask API
    try {
      final response = await http.post(
        Uri.parse('https://003f-223-123-97-182.ngrok-free.app/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        Map<String, dynamic> result = jsonDecode(response.body);
        Map<String, double> rawBudget = Map<String, double>.from(result['suggested_budget']);

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
    }
    finally {
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
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter your goal for this month",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (goalController.text.isNotEmpty) {
                      int goal = int.parse(goalController.text);
                      fetchAndSendDataToModel(goal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    "SEND",
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
                SizedBox(width: 20,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ScraperPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Scraping",
                          style: TextStyle(fontSize: 18,color: Colors.white),
                        ),
                      ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                            style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${amount.toString()}",
                            style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
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
