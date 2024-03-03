import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/add_record_screen.dart';
import 'package:my_app_frontend/view/home_screen.dart';
import 'package:my_app_frontend/view/login_screen.dart';
import 'package:my_app_frontend/view/medical_record_page.dart';
import 'package:my_app_frontend/view/sign_in_screen.dart';
import 'package:my_app_frontend/view/welcome_screen.dart';

class Welcome2Screen extends StatefulWidget {
  const Welcome2Screen({super.key});

  @override
  State<Welcome2Screen> createState() => _Welcome2ScreenState();
}

class _Welcome2ScreenState extends State<Welcome2Screen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: size.height / 3,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image:
                      AssetImage("assets/images/medicine-removebg-preview.png"),
                )),
              ),
              const Column(
                children: [
                  Text(
                    "Check your medical history with us",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "MedHistory App ! take charge of your health journey with our easy-to-use-platform,that helps users easily store ,manage, and access their medical history.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 97, 97, 97),
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()));
                    },
                    color: GlobalColors.mainColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
