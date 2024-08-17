
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/add.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/dashboard_view.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/goals.dart';
import 'package:personal_cash_flow_navigator/Features/User/View/profile_view.dart';


class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _pageIndex = 1;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  User? _currentUser;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      setState(() {
        _pages = [
          DashboardView(),
          Add_Screen(),
          BudgetSuggestionScreen(),



        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 1,
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.dashboard, color: Colors.deepOrange,),
            label: 'Dashboard',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.add,color: Colors.deepOrange,),
            label: 'ADD',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.bolt,color: Colors.deepOrange,),
            label: 'Goals',
          ),


        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: _pages.isNotEmpty ? _pages[_pageIndex] : Center(child: CircularProgressIndicator()),
    );
  }
}
