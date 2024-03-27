import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/welcome2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a timer to navigate after 2 seconds
    Timer(const Duration(seconds: 3), () {
      // Check if a session is available
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Navigate to MainNavigation if a session is available
        Get.offAllNamed('/mainNavigation');
      } else {
        // Navigate to Welcome2Screen if no session is available
        Get.offAllNamed('/welcome2');
      }
    });
    // Use a timer to navigate to LoginPage after 2 seconds
    /*Timer(const Duration(seconds: 3), () {
      Get.to(Welcome2Screen());
    });*/
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      body: Center(
        child: Text(
          'MedHistory',
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              letterSpacing: .5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
