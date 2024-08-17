import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:excel/excel.dart';

import '../../snakbar.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  DateTime? selectedDate;
  String? selectedCategoryId;
  TextEditingController categoryController = TextEditingController();
  List<Map<String, dynamic>> expensesWithCategoryNames = [];

  final Map<String, String> categories = {
    "Savings": "72pCELsgpDvrofbvNnws",
    "Entertainment": "GTDYKvrwN7nH9HgksOEX",
    "Healthcare": "WL66RzS1V4MGJBjvHILG",
    "Utilities": "e6wZVkLmvoNREP1e7bYH",
    "Personal Care": "gG5NJ5gZL4oWBuNA9Bzz",
    "Education": "oSSE0oGBu5nCuUXEVO5X",
    "Transportation": "rCwv8eMw5SeG81DsKH61",
    "Others": "yHahRPnDANZhVB2qn9CQ",
    "Food": "yjmdQrZ2h5J7HURBB37q"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Expenses"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: IgnorePointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: selectedDate == null
                              ? "Select Date"
                              : DateFormat('dd-MM-yyyy').format(selectedDate!),
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectCategory(context),
                    child: IgnorePointer(
                      child: TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          hintText: "Select Category",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.orange),
                  onPressed: _searchExpenses,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.orange),
                  onPressed: _clearFields,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: expensesWithCategoryNames.length,
                itemBuilder: (context, index) {
                  final expense = expensesWithCategoryNames[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(expense['Name']),
                      subtitle: Text(
                          "Category: ${expense['CategoryName']} \nDate: ${DateFormat('dd-MM-yyyy').format(expense['Date'].toDate())}"),
                      trailing: Text("Price: ${expense['Price']}"),
                      onTap: () => _editExpense(context,expense),
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteExpense(expense['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed:() =>  _exportToExcel(context),
              child: const Text("Export to Excel"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectCategory(BuildContext context) async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Category"),
          children: categories.entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, entry.key);
              },
              child: Text(entry.key),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        categoryController.text = selected;
        selectedCategoryId = categories[selected];
      });
    }
  }

  Future<void> _searchExpenses() async {
    if (selectedDate == null && selectedCategoryId == null) {
     // _showMessage("Please select a Date or Category.");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Query query = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Expenses');

        if (selectedDate != null) {
          DateTime startOfDay = DateTime(
              selectedDate!.year, selectedDate!.month, selectedDate!.day);
          DateTime endOfDay = startOfDay.add(const Duration(days: 1));
          query = query
              .where('Date', isGreaterThanOrEqualTo: startOfDay)
              .where('Date', isLessThan: endOfDay);
        }

        if (selectedCategoryId != null) {
          query = query.where('CategoryId', isEqualTo: selectedCategoryId);
        }

        QuerySnapshot expenseSnapshot = await query.get();

        List<Map<String, dynamic>> loadedExpenses = [];

        for (var expenseDoc in expenseSnapshot.docs) {
          String categoryId = expenseDoc['CategoryId'];
          String categoryName = await _getCategoryName(categoryId, user.uid);

          loadedExpenses.add({
            'id': expenseDoc.id,
            'Name': expenseDoc['Name'],
            'Price': expenseDoc['Price'],
            'CategoryName': categoryName,
            'Date': expenseDoc['Date'],
          });
        }

        setState(() {
          expensesWithCategoryNames = loadedExpenses;
        });

        if (loadedExpenses.isEmpty) {
         // _showMessage("No expenses found for the selected criteria.");
        }
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    //  _showMessage("An error occurred while searching for expenses.");
    }
  }

  Future<String> _getCategoryName(String categoryId, String userId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .get();

      if (categoryDoc.exists) {
        return categoryDoc['Name'] ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching category name: $e');
    }
    return 'Unknown';
  }

  Future<void> _deleteExpense(String expenseId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Expenses')
            .doc(expenseId)
            .delete();
        _searchExpenses(); // Refresh the list after deletion
      }
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  void _editExpense(BuildContext context, Map<String, dynamic> expense) {
    TextEditingController nameController =
    TextEditingController(text: expense['Name']);
    TextEditingController priceController =
    TextEditingController(text: expense['Price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .collection('Expenses')
                        .doc(expense['id'])
                        .update({
                      'Name': nameController.text,
                      'Price': double.parse(priceController.text),
                    });
                    _searchExpenses(); // Refresh the list after editing
                  }
                } catch (e) {
                  print('Error updating expense: $e');
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    setState(() {
      selectedDate = null;
      selectedCategoryId = null;
      categoryController.clear();
      expensesWithCategoryNames.clear();
    });
  }







  Future<void> _exportToExcel(BuildContext context) async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Storage permission not granted.");
      SnackbarHelper.show(context, "Storage permission not granted.");
      return;
    }

    var excel = Excel.createExcel(); // Create a new Excel file
    Sheet sheet = excel['Sheet1']; // Access the default sheet

    // Add header row
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Category'),
      TextCellValue('Price'),
      TextCellValue('Date'),
    ]);

    // Add data rows
    for (var expense in expensesWithCategoryNames) {
      sheet.appendRow([
        TextCellValue(expense['Name']),
        TextCellValue(expense['CategoryName']),
        DoubleCellValue(expense['Price']),
        TextCellValue(DateFormat('yyyy-MM-dd').format(expense['Date'].toDate())), // Convert timestamp to DateTime
      ]);

      // Print each row to the terminal
      print([
        expense['Name'],
        expense['CategoryName'],
        expense['Price'],
        DateFormat('yyyy-MM-dd').format(expense['Date'].toDate()), // Convert timestamp to DateTime
      ]);
    }

    // Get the path to the external directory where you want to save the file
    Directory? directory = await getExternalStorageDirectory();
    String outputFile = '${directory?.path}/expenses_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';

    List<int>? fileBytes = excel.save();

    if (fileBytes != null) {
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }


    print("Excel file saved at: $outputFile");
    SnackbarHelper.show(context, "$outputFile");
  }





}
