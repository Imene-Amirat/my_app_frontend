import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/favorite_record_screen.dart';
import 'package:my_app_frontend/view/home_screen.dart';
import 'package:my_app_frontend/view/medical_record_page.dart';
import 'package:my_app_frontend/view/profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  //current index var
  int _selectedIndex = 0;

  //lis of screen that we want navigate between
  List<Widget> _screens = [
    HomeScreen(),
    FavoriteRecordsScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            color: GlobalColors.mainColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: GNav(
              backgroundColor: GlobalColors.mainColor,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor:
                  //Color.fromARGB(255, 81, 176, 240).withOpacity(0.7),
                  Color.fromARGB(255, 93, 136, 163).withOpacity(0.7),
              gap: 8,
              padding: EdgeInsets.all(10),
              tabs: const [
                GButton(
                  icon: LineAwesomeIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.heart,
                  text: 'Likes',
                ),
                GButton(
                  icon: Iconsax.user,
                  text: 'Profile',
                ),
              ],
              onTabChange: (i) {
                setState(() {
                  _selectedIndex = i;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
