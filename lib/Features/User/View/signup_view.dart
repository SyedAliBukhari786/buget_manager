import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/bottomnavigatorbar_view.dart';

import '../../snakbar.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _totalIncomeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _signUp() async {
    String username = _usernameController.text;
    String contact = _contactController.text;
    String totalIncomeStr = _totalIncomeController.text;

    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (!_validateInputs(username, contact, totalIncomeStr,  email, password, confirmPassword)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      double totalIncome = double.parse(totalIncomeStr);


      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({
          'username': username,
          'contact': contact,
          'totalIncome': totalIncome,
          'email': email,
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      SnackbarHelper.show(context, e.message ?? 'Sign Up Failed');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateInputs(String username, String contact, String totalIncomeStr,  String email, String password, String confirmPassword) {
    if (username.isEmpty) {
      SnackbarHelper.show(context, 'Username cannot be empty');
      return false;
    }
    if (contact.isEmpty || !RegExp(r'^\d{11}$').hasMatch(contact)) {
      SnackbarHelper.show(context, 'Contact must be exactly 11 digits');
      return false;
    }
    if (totalIncomeStr.isEmpty || double.tryParse(totalIncomeStr) == null || double.parse(totalIncomeStr) <= 0) {
      SnackbarHelper.show(context, 'Total Income must be a number greater than 0');
      return false;
    }

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      SnackbarHelper.show(context, 'Invalid email address');
      return false;
    }
    if (password.isEmpty || password.length < 8) {
      SnackbarHelper.show(context, 'Password must be at least 8 characters');
      return false;
    }
    if (password != confirmPassword) {
      SnackbarHelper.show(context, 'Passwords do not match');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: screenWidth * 0.5,
                width: screenWidth * 0.85,
                child: Lottie.asset("assets/logomain.json"),
              ),
              SizedBox(height: 10),
              Text(
                "Personal Cash Flow",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact',
                    prefixIcon: Icon(Icons.phone, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _totalIncomeController,
                  decoration: InputDecoration(
                    labelText: 'Total Income',
                    prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),


              SizedBox(height: 10),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: screenWidth * 0.8,
                child: TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Container(
                width: screenWidth * 0.8,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 50,
        child: Container(
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Already Have an Account? ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Sign in",
                    style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
