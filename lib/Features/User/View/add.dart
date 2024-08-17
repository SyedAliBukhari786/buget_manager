import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Add_Screen extends StatefulWidget {
  const Add_Screen({super.key});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image;
  String _detectedText = 'No text detected';

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _performOCR();
    }
  }

  Future<void> _performOCR() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFilePath(_image!.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String extractedPrice = 'No price found';
    String extractedDate = 'No date found';
    StringBuffer fullText = StringBuffer();

    List<TextBlock> blocks = recognizedText.blocks;
    blocks.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    for (TextBlock block in blocks) {
      block.lines.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      for (TextLine line in block.lines) {
        fullText.write(line.text + ' ');
      }
      fullText.write('\n');
    }

    _detectedText = fullText.toString();

    RegExp grandTotalRegex = RegExp(r'Grand Total\s*([\d,]+\.\d{2}|\d+)');
    Match? matchPrice = grandTotalRegex.firstMatch(_detectedText);

    if (matchPrice != null) {
      extractedPrice = matchPrice.group(1)!;
    }

    RegExp dateRegex = RegExp(r'\b(\d{1,2}-[A-Za-z]{3}-\d{2})\b');
    Match? matchDate = dateRegex.firstMatch(_detectedText);

    if (matchDate != null) {
      extractedDate = matchDate.group(1)!;
      DateTime parsedDate = DateFormat('d-MMM-yy').parse(extractedDate);
      extractedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      setState(() {
        selectedDate = parsedDate;
        dateController.text = extractedDate;
      });
    }

    setState(() {
      priceController.text = extractedPrice;
      _detectedText = _detectedText;
    });

    textRecognizer.close();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveData(BuildContext context, String categoryId) async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedDate == null ||
        double.tryParse(priceController.text) == null ||
        double.parse(priceController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Expenses')
          .add({
        'CategoryId': categoryId,
        'Name': nameController.text,
        'Price': double.parse(priceController.text),
        'Date': Timestamp.fromDate(selectedDate!),
      });
      Navigator.pop(context); // Close the dialog
    }
  }

  Future<void> _showAddExpenseDialog(BuildContext context, String categoryId, String categoryName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense in $categoryName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    icon: Icon(Icons.text_fields, color: Colors.orange),
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    icon: Icon(Icons.money, color: Colors.orange),
                  ),
                ),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: TextStyle(color: Colors.orange),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    icon: Icon(Icons.calendar_today, color: Colors.orange),
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: _pickImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Scan through photo"),
                      Icon(Icons.camera_front, color: Colors.green),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                _saveData(context, categoryId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data Added Successfully')),
                );
              },
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
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
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('Categories').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories found.'));
          } else {
            var categories = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                String imageName = category['Name'].toLowerCase().replaceAll(' ', '_');
                String imagePath = 'assets/$imageName.png';

                return GestureDetector(
                  onTap: () => _showAddExpenseDialog(context, category.id, category['Name']),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.all(8.0),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              height: 80,
                            ),
                          ),
                          SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              category['Name'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
