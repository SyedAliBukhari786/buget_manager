import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:personal_cash_flow_navigator/Features/Admin/dashboard.dart';
import 'package:personal_cash_flow_navigator/selection_screen.dart';
import 'package:personal_cash_flow_navigator/splashscreen.dart';
import 'Features/User/View/Scraping.dart';
import 'Features/User/View/bottomnavigatorbar_view.dart';
import 'Features/User/View/editexcel.dart';
import 'Features/User/View/urltesting.dart';
import 'firebase_options.dart';

//BuyersDashboardView  BuyersDashboardView


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Cash Flow Navigator',
      home: FutureBuilder<Widget>(
        future: _checkUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data ?? Selection_Screen();
;
          }
        },
      ),
    );
  }

  Future<Widget> _checkUserType() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return SplashScreen();
;
    }

    final currentUserId = firebaseUser.uid;

    final adminDoc = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(currentUserId)
        .get();
    if (adminDoc.exists) {
      return AdminDashboard();
();
    }


    final sellerDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .get();
    if (sellerDoc.exists) {
      return  BottomNavBar();
    }

    return Selection_Screen();
(); // Fallback in case the user is not found in any collection
  }
}
