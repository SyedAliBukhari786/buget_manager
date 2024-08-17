import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:personal_cash_flow_navigator/Features/Admin/adminlogin.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/login_view.dart';


class Selection_Screen extends StatefulWidget {
  const Selection_Screen({super.key});

  @override
  State<Selection_Screen> createState() => _Selection_ScreenState();
}

class _Selection_ScreenState extends State<Selection_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Text("Continue as", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
              SizedBox(height: 50,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   Adminlogin()),
                  );
                },
                child: Container(
                  height: 150,
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Center(
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                            child: Lottie.asset("assets/admin.json")
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 50,),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()));

                },
                child: Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Center(
                            child: Text(
                              "User",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                            child: Lottie.asset("assets/buyers.json")
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
