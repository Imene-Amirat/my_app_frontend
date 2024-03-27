import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/utils/global_colors.dart';

class DoctorsDirectoryScreen extends StatefulWidget {
  static final pageRoute = '/doctors_directory';
  const DoctorsDirectoryScreen({super.key});

  @override
  State<DoctorsDirectoryScreen> createState() => _DoctorsDirectoryScreenState();
}

class _DoctorsDirectoryScreenState extends State<DoctorsDirectoryScreen> {
  String _tx_search_filter_name = '';
  int? _tx_search_filter_sp;
  int? _tx_search_filter_rg;
  String? dropdownValueSp = null;
  String? dropdownValueCity = null;
  int? selectedCityId;
  int? selectedSpecialtyId;
  //list of maps (or objects) where each map represents a specialty with at least two keys: name and id.
  List<Map<String, dynamic>> specialties = [];
  List<Map<String, dynamic>> city = [];
  List<Map<String, dynamic>> regions = [];
  List<Map<String, dynamic>> doctors = [];

  // Controllers for new doctor information
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSpCountry().then((_) {
      _determinePosition();
    });
  }

  Future<List<Map>> getListDoctors(
    String filter_name,
    String filter_sp,
    String filter_rg,
  ) async {
    try {
      // Construct the query parameters
      final queryParams = {
        if (filter_name.isNotEmpty) 'name': filter_name,
        if (filter_sp != null && filter_sp.isNotEmpty) 'specialty': filter_sp,
        if (filter_rg != null && filter_rg.isNotEmpty) 'address': filter_rg,
      };
      // Construct the URL with parameters
      final uri = Uri.https(
        'flask-app-medical.vercel.app',
        '/doctor.get',
        queryParams,
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        doctors = jsonData.map((doctorData) {
          return {
            "name": doctorData['Name'],
            "sp": doctorData['Specialty'],
            "rg": doctorData['Address'],
          };
        }).toList();
        print("kkkkkkkkkkkkkkkkk");
        print(doctors);
      } else {
        print('Failed to load options. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading options: $e');
    }
    return doctors;
  }

  Future<void> _updateDoctorsList() async {
    setState(() {});
  }

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
        _tx_search_filter_rg = selectedCityId;
      });
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
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
                  _tx_search_filter_sp = selectedSpecialtyId;
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
                  print(city);
                  // hold the selected specialty ID && "firstWhere" find the first element that matches a given newValue and return id.
                  selectedCityId = city
                      .firstWhere((wilaya) => wilaya['name'] == newValue)['id'];
                  print(selectedCityId);
                  _tx_search_filter_rg = selectedCityId;
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
                  dropdownValueSp ?? '',
                  dropdownValueCity ?? ''), // This fetches the latest list
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
          String doctorName = items[index]['name'] ?? 'Unknown Name';
          String specialty = items[index]['sp'] ?? 'Unknown Specialty';
          String address = items[index]['rg'] ?? 'Unknown Address';

          return GestureDetector(
            onTap: () {
              // Navigator.pop(context, items[index]); // Be careful with this line if you're not in a dialog or modal.
            },
            child: Card(
              elevation: 10,
              child: ListTile(
                title: Text(doctorName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(specialty),
                    Text(address),
                  ],
                ),
                // Add trailing to show the delete icon...
              ),
            ),
          );
        },
      );
    } else if (snapshot.hasError) {
      return Text("Error: ${snapshot.error}");
    }
    return CircularProgressIndicator();
  }
}
