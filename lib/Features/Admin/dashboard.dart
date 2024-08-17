import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    final users = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _searchUser(String query) {
    final filtered = _users.where((user) {
      final contact = user['contact'].toString();
      return contact.contains(query);
    }).toList();
    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController usernameController = TextEditingController(text: user['username']);
        final TextEditingController contactController = TextEditingController(text: user['contact']);
        final TextEditingController totalIncomeController = TextEditingController(text: user['totalIncome'].toString());

        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: totalIncomeController,
                decoration: const InputDecoration(labelText: 'Total Income'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedUser = {
                  'username': usernameController.text,
                  'contact': contactController.text,
                  'totalIncome': int.tryParse(totalIncomeController.text) ?? 0,
                };

                await FirebaseFirestore.instance
                    .collection('User')
                    .doc(user['contact']) // Assuming 'contact' is the unique identifier
                    .update(updatedUser);

                _fetchUsers();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarChartData() {
    return _filteredUsers.asMap().entries.map((entry) {
      int index = entry.key;
      var user = entry.value;
      double income = user['totalIncome'].toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    }).toList();
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.logout, color: Colors.orange),
            onPressed: () async {
              // Handle menu icon press
              await FirebaseAuth.instance.signOut();

              // Navigate to the login screen and prevent going back
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Selection_Screen()), // Replace LoginScreen with your actual login screen widget
              );
            },
          ),
        title: const Text('Admin Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUser,
              decoration: const InputDecoration(
                hintText: 'Search by contact number...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Users Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _buildBarChartData(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                          return Text('${_filteredUsers[value.toInt()]['username']}');
                        }),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(

                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final user = _filteredUsers[group.x.toInt()];
                          return BarTooltipItem(
                            '${user['username']}\n\$${rod.toY}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'User List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Card(
                    child: ListTile(
                      title: Text(user['username']),
                      subtitle: Text('Contact: ${user['contact']}\nTotal Income: \$${user['totalIncome']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editUser(user),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
