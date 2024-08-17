import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/signup_view.dart';

import '../../snakbar.dart';
import '../Controller/sign_in_controller.dart';
import 'bottomnavigatorbar_view.dart';



class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInController _signInController = SignInController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!_validateInputs(email, password)) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await _signInController.signIn(email, password);
    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } else {
      SnackbarHelper.show(context, 'Sign In Failed');
    }
  }

  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.show(context, 'All fields are required');
      return false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      SnackbarHelper.show(context, 'Invalid email address');
      return false;
    }
    if (password.length < 8) {
      SnackbarHelper.show(context, 'Password must be at least 8 characters');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,color: Colors.green,),
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
                    prefixIcon: Icon(Icons.lock,color: Colors.green,),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
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
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Container(
                width: screenWidth * 0.8,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Sign In'),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                ],
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=> SignupView()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Sign up",
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
