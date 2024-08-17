import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/bugetprediction.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/buggestsuggestion.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/profile_view.dart';
import 'CalculationWiget.dart';
import 'Scraping.dart';
import 'SearchWidget.dart';
import 'login_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String totalIncome = "Loading...";
  double monthlyExpense = 0.0;
  bool isYearly = true;
  String selectedMonth = '1-2024';
  Map<String, double> expenses = {};
  Map<String, double> categoryExpenses = {};
  List<String> monthOptions = [];
  bool show =false;

  @override
  void initState() {
    super.initState();
    _calculateExpenses();
    _getTotalIncome();
    _getYearlyExpenses();
    _initializeMonthOptions(); // Load month options for the dropdown
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


        double totalMonthly = 0.0;
        DateTime now = DateTime.now();


        String currentMonth = "${now.month}-${now.year}";


        for (var doc in expensesSnapshot.docs) {
          Timestamp timestamp = doc['Date'];
          DateTime date = timestamp.toDate();
          double price = double.parse(doc['Price'].toString());



          if (isSameMonth(date, now)) {
            totalMonthly += price;
          }


        }

        setState(() {

          monthlyExpense = totalMonthly;

        });
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  void _initializeMonthOptions() {
    List<String> months = List.generate(12, (index) => '${index + 1}-2024');
    setState(() {
      monthOptions = months;
    });
  }

  Future<void> _getTotalIncome() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            if(monthlyExpense>userDoc['totalIncome'])
              {
                show=true;


              }
            totalIncome = userDoc['totalIncome'].toString();
          });
        } else {
          setState(() {
            totalIncome = "No income data";
          });
        }
      } else {
        setState(() {
          totalIncome = "User not logged in";
        });
      }
    } catch (e) {
      setState(() {
        totalIncome = "Error loading income";
      });
    }
  }

  Future<void> _getYearlyExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Expenses')
            .get();

        Map<String, double> yearlyExpenses = {};
        for (var doc in expensesSnapshot.docs) {
          Timestamp timestamp = doc['Date'];
          String month = "${timestamp.toDate().month}-${timestamp.toDate().year}";
          double price = double.parse(doc['Price'].toString());

          yearlyExpenses[month] = (yearlyExpenses[month] ?? 0) + price;
        }

        setState(() {
          expenses = yearlyExpenses;
        });
      }
    } catch (e) {
      print('Error fetching yearly expenses: $e');
    }
  }

  Future<void> _getCategoryExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Expenses')
            .where('Date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2024, int.parse(selectedMonth.split('-')[0]), 1)))
            .where('Date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(2024, int.parse(selectedMonth.split('-')[0]), 31)))
            .get();

        Map<String, double> categoryExpenses = {};
        for (var doc in expensesSnapshot.docs) {
          String categoryId = doc['CategoryId'];
          double price = double.parse(doc['Price'].toString());

          DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
              .collection('Categories')
              .doc(categoryId)
              .get();
          String categoryName = categoryDoc['Name'];

          categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + price;
        }

        setState(() {
          this.categoryExpenses = categoryExpenses;
        });
      }
    } catch (e) {
      print('Error fetching category expenses: $e');
    }
  }


  List<BarChartGroupData> _buildBarChartData(Map<String, double> data) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.cyan];
    int index = 0;

    return data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: colors[index++ % colors.length],
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }


  void _showBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Exceeded'),
          content: Text('You have exceeded your monthly budget.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.orange),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the navigation drawer
            },
          ),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$totalIncome',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 3,),
          (show==true)?GestureDetector(onTap: () {
            _showBudgetDialog(context);
          },child: Icon(Icons.error_outline, color: Colors.red,)):SizedBox()
              ],
            ),

            Text(
              "Total Income",
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.orange),
            onPressed: () {
              // Navigate to the SearchWidget
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchWidget()),
              );
            },
          ),
        ],
      ),


      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/logomain.json', height: 100), // Replace with your Lottie asset
                    Text(
                      'Personal Cash Flow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.red),
              title: Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView()), // Replace with your Profile screen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.red),
              title: Text('Budget Suggestion', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Buggestsuggestion()), // Replace with your Budget Suggestion screen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on_rounded, color: Colors.red),
              title: Text('Budget Prediction', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetPrediction()), // Replace with your Budget Prediction screen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () async {
                // Handle logout
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()), // Replace with your Login screen
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Personal Cash Flow", style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.bold),),
                Lottie.asset("assets/logomain.json", width: 60, height: 60)
              ],
            ),

            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Your Cash Flow Yearly", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Container(
                height: 220,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: _buildBarChartData(expenses),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _getMonthName(expenses.keys.firstWhere(
                                    (key) => key.hashCode == value.toInt(),
                                orElse: () => '',
                              )),
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toString(),
                            TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 10,),
            Calculationwiget(),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Your Cash Flow Monthly", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedMonth,
                      items: monthOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(_getMonthName(value)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonth = newValue!;
                        });
                        _getCategoryExpenses(); // Fetch category expenses for the selected month
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: _buildBarChartData(categoryExpenses),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    categoryExpenses.keys.firstWhere(
                                          (key) => key.hashCode == value.toInt(),
                                      orElse: () => '',
                                    ),
                                    style: TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  rod.toY.toString(),
                                  TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  String _getMonthName(String key) {
    int month = int.parse(key.split('-')[0]);
    List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return monthNames[month - 1];
  }
}
