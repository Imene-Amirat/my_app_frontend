import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/navigation.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/Appointment_list.dart';
import 'package:my_app_frontend/view/Appointment_page.dart';
import 'package:my_app_frontend/view/doctors_directory_screen.dart';
import 'package:my_app_frontend/view/family_member_screen.dart';
import 'package:my_app_frontend/view/profile_screen.dart';
import 'package:my_app_frontend/view/doctor_screen.dart';
import 'package:my_app_frontend/view/home_screen.dart';
import 'package:my_app_frontend/view/login_screen.dart';
import 'package:my_app_frontend/view/medical_record_page.dart';
import 'package:my_app_frontend/view/splash_screen.dart';
import 'package:my_app_frontend/view/success_booked.dart';
import 'package:my_app_frontend/view/welcome2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDataFetched = prefs.getBool('isDataFetched') ?? false;

  if (!isDataFetched) {
    //await fetchDoctorsData();
    fetchDoctorsFromJsonFile();
    await prefs.setBool('isDataFetched', true);
  }

  await Supabase.initialize(
    url: "https://ghwerggdepsautiaodrd.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdod2VyZ2dkZXBzYXV0aWFvZHJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcwNzc4MjEsImV4cCI6MjAyMjY1MzgyMX0.LERXigL5LYEqmOQysJ9mhWkS8QWj8lXDn2Waae23HiQ",
  );

  runApp(const MyApp());
}

Future<void> fetchDoctorsFromJsonFile() async {
  // Read the JSON file from the assets
  final jsonString = await rootBundle.loadString('assets/doc/results.jsonl');

  // Split the file content by line breaks to get each JSON object line
  final lines = LineSplitter.split(jsonString);

  for (var line in lines) {
    try {
      // Parse the line into a JSON object
      final doctor = json.decode(line);

      // Insert the doctor into the database
      final int id = await DBDoctor.insertDoctor1({
        "name": doctor['Name'],
        "specialty": doctor['Specialty'],
        "wilaya": doctor['Address'],
      });

      // Optional: print the inserted doctor's ID
      print('Inserted doctor with id $id');
    } catch (e) {
      print('Failed to insert doctor: $e');
    }
  }
}

/*Future<void> fetchDoctorsData() async {
  int page = 1;
  final int limit = 100; // Set a limit for page size, adjust as needed
  bool hasMore = true; // Flag to check if there's more data to fetch

  while (hasMore) {
    try {
      // Fetch data for the current page
      final response = await http.get(Uri.parse(
          'https://flask-app-medical.vercel.app/doctor.get?page=$page&limit=$limit'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // If no data is returned, we've reached the end
        if (jsonData.isEmpty) {
          hasMore = false;
        } else {
          // Process the data and insert into the database
          List<Map<String, dynamic>> doctors = jsonData.map((doctorData) {
            return {
              "name": doctorData['Name'],
              "specialty": doctorData['Specialty'],
              "wilaya": doctorData['Address'],
            };
          }).toList();

          for (var doctor in doctors) {
            await DBDoctor.insertDoctor1(doctor);
          }

          // Increment the page index for the next API call
          page++;
        }
      } else {
        print(
            'Failed to fetch doctors data. Status code: ${response.statusCode}');
        hasMore = false; // Stop if the request failed
      }
    } catch (e) {
      print('Error fetching doctors data: $e');
      hasMore = false; // Stop if an exception occurred
    }
  }
}*/

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
      /*initialRoute: supabase.auth.currentSession != null
          ? '/mainNavigation'
          : '/welcome2',*/
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/home': (context) => HomeScreen(),
        '/medicalRecords': (context) => MedicalRecordsPage(),
        '/familyMembers': (context) => FamilyMembersPage(),
        '/welcome2': (context) => Welcome2Screen(),
        '/mainNavigation': (context) => MainNavigator(),
        '/appointment': (context) => Appointment(),
        '/appointmentlist': (context) => AppointmentPage(),
        '/doctors_directory': (context) => DoctorsDirectoryScreen(),
        MedicalRecordsPage.pageRoute: (context) => MedicalRecordsPage(),
        '/success_booked': (context) => AppointmentBooked(),
        AppointmentBooked.pageRoute: (context) => AppointmentBooked(),
        DoctorScreen.pageRoute: (context) => DoctorScreen(),
        DoctorsDirectoryScreen.pageRoute: (context) => DoctorsDirectoryScreen(),
        ProfileScreen.pageRoute: (context) => ProfileScreen(),
      },
      home: SplashScreen(),
    );
  }
}
