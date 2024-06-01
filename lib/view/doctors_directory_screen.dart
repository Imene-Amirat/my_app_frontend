import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorsDirectoryScreen extends StatefulWidget {
  static final pageRoute = '/doctors_directory';
  const DoctorsDirectoryScreen({super.key});

  @override
  State<DoctorsDirectoryScreen> createState() => _DoctorsDirectoryScreenState();
}

class _DoctorsDirectoryScreenState extends State<DoctorsDirectoryScreen>
    with WidgetsBindingObserver {
  String _tx_search_filter_name = '';
  String _tx_search_filter_sp = '';
  String _tx_search_filter_rg = '';
  String? dropdownValueSp = null;
  String? dropdownValueCity = null;
  int? selectedCityId;
  int? selectedSpecialtyId;
  //list of maps (or objects) where each map represents a specialty with at least two keys: name and id.
  List<Map<String, dynamic>> specialties = [];
  List<Map<String, dynamic>> city = [];

  // Controllers for new doctor information
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchSpCountry().then((_) {
      _determinePosition();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  Future<List<Map>> getListDoctors(
    String filter_name,
    String filter_sp,
    String filter_rg,
  ) async {
    String? userId = await getUserId();
    print(await DBDoctor.getAllDoctorsByKeyword(
        filter_name, filter_sp, filter_rg, userId!));
    return DBDoctor.getAllDoctorsByKeyword(
        filter_name, filter_sp, filter_rg, userId);
  }

  Future<void> _updateDoctorsList() async {
    setState(() {});
  }

  // This method will be called when the "Add New" button is pressed
  Future<void> fetchSpCountry() async {
    try {
      final url1 =
          Uri.parse('https://flask-app-medical.vercel.app/specialties.get');
      final url2 = Uri.parse('https://flask-app-medical.vercel.app/wilaya.get');

      //final response = await http.get(Uri.parse('https://flask-app-medical.vercel.app/records.type'));
      final response = await Future.wait([http.get(url1), http.get(url2)]);

      if (response[0].statusCode == 200) {
        List<dynamic> jsonData1 = json.decode(response[0].body);
        setState(() {
          specialties = jsonData1
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(specialties);
      } else {
        print('Failed to load options. Status code: ${response[0].statusCode}');
      }

      if (response[1].statusCode == 200) {
        List<dynamic> jsonData2 = json.decode(response[1].body);
        setState(() {
          city = jsonData2
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(city);
      } else {
        print('Failed to load options. Status code: ${response[1].statusCode}');
      }
    } catch (e) {
      print('Error loading options: $e');
    }
  }

  String _getSpecialtyNameById(int id) {
    var specialty = specialties.firstWhere((specialty) => specialty['id'] == id,
        orElse: () => {
              "id": -1,
              "name": 'loading....'
            } //data has not yet been fetched from the backend & HTTP request to fetch the specialties is still running
        );
    return specialty['name'];
  }

  String _getCitytyNameById(int id) {
    var wilaya = city.firstWhere((wilaya) => wilaya['id'] == id,
        orElse: () => {
              "id": -1,
              "name": 'loading....'
            } //data has not yet been fetched from the backend & HTTP request to fetch the specialties is still running
        );
    return wilaya['name'];
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Services Disabled'),
            content: Text('Please enable location services to continue.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Open location settings
                  Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                },
                child: Text('Open Settings'),
              ),
            ],
          );
        },
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);

    // Perform reverse geocoding
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      print(
          place); // You can print the entire Placemark object to see its structure
      String locationName = "${place.locality}";
      print(locationName); // This prints the city name and country

      // Update your state or UI with the location name
      setState(() {
        dropdownValueCity =
            locationName; // Or however you wish to use the location name
        String f =
            city.firstWhere((wilaya) => wilaya['name'] == locationName)['name'];
        print(f);
        selectedCityId = city.firstWhere((wilaya) => wilaya['name'] == f)['id'];
        print(selectedCityId);
        _tx_search_filter_rg = dropdownValueCity!;
      });
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check if the app is in resumed state
    if (state == AppLifecycleState.resumed) {
      // The app has returned to the foreground
      // Call your method to check location services and request permissions
      _determinePosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Doctors Directory",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: GlobalColors.mainColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left,
            size: 30,
          ),
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Profession Name',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  LineAwesomeIcons.medical_notes,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              keyboardType: TextInputType.text,
              onChanged: (newValue) {
                _tx_search_filter_name = newValue;
                setState(() {});
              },
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
              value: dropdownValueSp,
              decoration: InputDecoration(
                labelText: "Specialty",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  LineAwesomeIcons.medical_notes,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              dropdownColor: const Color.fromARGB(255, 255, 255, 255),
              onChanged: (dynamic newValue) {
                setState(() {
                  dropdownValueSp = newValue;
                  // hold the selected specialty ID && "firstWhere" find the first element that matches a given newValue and return id.
                  selectedSpecialtyId = specialties.firstWhere(
                      (specialty) => specialty['name'] == newValue)['id'];
                  print(selectedSpecialtyId);
                  _tx_search_filter_sp = dropdownValueSp!;
                });
                _updateDoctorsList();
              },
              items: specialties
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value['name'],
                  child: Text(value['name']),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
              value: dropdownValueCity,
              decoration: InputDecoration(
                labelText: "City",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  LineAwesomeIcons.medical_notes,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              dropdownColor: const Color.fromARGB(255, 255, 255, 255),
              onChanged: (dynamic newValue) {
                setState(() {
                  dropdownValueCity = newValue;
                  // hold the selected specialty ID && "firstWhere" find the first element that matches a given newValue and return id.
                  selectedCityId = city
                      .firstWhere((wilaya) => wilaya['name'] == newValue)['id'];
                  print(selectedCityId);
                  _tx_search_filter_rg = dropdownValueCity!;
                });
                _updateDoctorsList();
              },
              items: city
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
                return DropdownMenuItem<String>(
                  value: value['name'],
                  child: Text(value['name']),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: FutureBuilder<List<Map>>(
              future: getListDoctors(
                  _tx_search_filter_name,
                  _tx_search_filter_sp ?? '',
                  _tx_search_filter_rg ?? ''), // This fetches the latest list
              builder: (context, snapshot) =>
                  _build_list_doctors(context, snapshot),
            )),
          ],
        ),
      )),
    );
  }

  Widget _build_list_doctors(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<Map> items = snapshot.data!;
      //loading indicator until the data is fully fetched sp
      if (specialties.isEmpty) {
        // Data is still loading, show a placeholder or loading indicator
        return Center(child: CircularProgressIndicator());
      }
      if (city.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, items[index]);
            },
            child: Card(
              elevation: 10,
              child: ListTile(
                title: Text(items[index]['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[index]['specialty']),
                    Text(items[index]['wilaya']),
                  ],
                ),
                // Add trailing to show the delete icon
                trailing: items[index]['user_id'] != null
                    ? IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: const Color.fromARGB(255, 138, 132, 132),
                        ),
                        onPressed: () {
                          // Show dialog to confirm deletion
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete Doctor"),
                                  content: Text(
                                      "Are you sure you want to delete this doctor?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); //close the dialog
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Perform the deletion
                                        await DBDoctor.deleteDoctor(
                                            items[index]['doctor_id']);
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        _updateDoctorsList(); // Refresh the list
                                      },
                                      child: Text("Delete"),
                                    )
                                  ],
                                );
                              });
                        },
                      )
                    : null,
              ),
            ),
          );
        },
      );
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return CircularProgressIndicator();
  }
}
