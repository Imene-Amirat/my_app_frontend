import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app_frontend/navigation.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/family_member_screen.dart';
import 'package:my_app_frontend/view/profile_screen.dart';
import 'package:my_app_frontend/view/doctor_screen.dart';
import 'package:my_app_frontend/view/home_screen.dart';
import 'package:my_app_frontend/view/login_screen.dart';
import 'package:my_app_frontend/view/medical_record_page.dart';
import 'package:my_app_frontend/view/welcome2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ghwerggdepsautiaodrd.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdod2VyZ2dkZXBzYXV0aWFvZHJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcwNzc4MjEsImV4cCI6MjAyMjY1MzgyMX0.LERXigL5LYEqmOQysJ9mhWkS8QWj8lXDn2Waae23HiQ",
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static Color primaryColor = GlobalColors.mainColor;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedHistory',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: GlobalColors.mainColor),
          brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      //if our current session is available show home else show login
      initialRoute: supabase.auth.currentSession != null
          ? '/mainNavigation'
          : '/welcome2',
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/home': (context) => HomeScreen(),
        '/medicalRecords': (context) => MedicalRecordsPage(),
        '/familyMembers': (context) => FamilyMembersPage(),
        '/welcome2': (context) => Welcome2Screen(),
        '/mainNavigation': (context) => MainNavigator(),
        //'/appointment': (context) => Appointment(),
        //'/appointmentlist': (context) => AppointmentPage(),
        MedicalRecordsPage.pageRoute: (context) => MedicalRecordsPage(),
        //'/success_booked': (context) => AppointmentBooked(),
        DoctorScreen.pageRoute: (context) => DoctorScreen(),
        ProfileScreen.pageRoute: (context) => ProfileScreen(),
      },
      home: LoginScreen(),
    );
  }
}
