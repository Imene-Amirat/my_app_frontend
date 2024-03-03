import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBdoctor.dart';
import 'package:my_app_frontend/utils/global_colors.dart';

class DoctorScreen extends StatefulWidget {
  static final pageRoute = '/doctor';
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String _tx_search_filter = '';
  String? dropdownValueSp = null;
  String? dropdownValueCountry = null;
  int? selectedCountryId;
  int? selectedSpecialtyId;
  //list of maps (or objects) where each map represents a specialty with at least two keys: name and id.
  List<Map<String, dynamic>> specialties = [];
  List<Map<String, dynamic>> countries = [];

  // Controllers for new doctor information
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSpCountry();
  }

  Future<List<Map>> getListDoctors(String filter) async {
    print(await DBDoctor.getAllDoctorsByKeyword(filter));
    return DBDoctor.getAllDoctorsByKeyword(filter);
  }

  Future<void> _updateDoctorsList() async {
    setState(() {});
  }

  // This method will be called when the "Add New" button is pressed
  Future<void> _add() async {
    if (nameController.text.isNotEmpty &&
        selectedCountryId != null &&
        selectedSpecialtyId != null) {
      // Call the method to insert the new doctor into the database
      //! tells the Dart analyzer that you are sure these values won't be null at this point in the code.
      await DBDoctor.insertDoctor(
          nameController.text, selectedSpecialtyId!, selectedCountryId!);
      //clear the fields after insertion
      nameController.clear();
      setState(() {
        dropdownValueSp = null;
        dropdownValueCountry = null;
      });
      //Close the dialog
      Navigator.of(context).pop();
      // Update the list of doctors to reflect the new addition
      _updateDoctorsList();
    } else {
      //case where not all fields are filled
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all the fields.'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _addNewDoctor() async {
    // Show dialog to input details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Doctor"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  controller: nameController,
                ),
                DropdownButtonFormField(
                  value: dropdownValueSp,
                  decoration: InputDecoration(
                    labelText: "Specialty",
                  ),
                  dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                  onChanged: (dynamic newValue) {
                    setState(() {
                      dropdownValueSp = newValue;
                      // hold the selected specialty ID && "firstWhere" find the first element that matches a given newValue and return id.
                      selectedSpecialtyId = specialties.firstWhere(
                          (specialty) => specialty['name'] == newValue)['id'];
                      print(selectedSpecialtyId);
                    });
                  },
                  items: specialties.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> value) {
                    return DropdownMenuItem<String>(
                      value: value['name'],
                      child: Text(value['name']),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField(
                  value: dropdownValueCountry,
                  decoration: InputDecoration(labelText: 'Country'),
                  dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                  onChanged: (dynamic newValue) {
                    setState(() {
                      dropdownValueCountry = newValue;
                      // hold the selected country ID
                      selectedCountryId = countries.firstWhere(
                          (country) => country['name'] == newValue)['id'];
                      print(selectedCountryId);
                    });
                  },
                  items: countries.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> value) {
                    return DropdownMenuItem<String>(
                      value: value['name'],
                      child: Text(value['name']),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                _add();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchSpCountry() async {
    try {
      final url1 =
          Uri.parse('https://flask-app-medical.vercel.app/specialties.get');
      final url2 =
          Uri.parse('https://flask-app-medical.vercel.app/countries.get');

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
          countries = jsonData2
              .map((option) => {"id": option['id'], "name": option['name']})
              .toList();
        });
        print(countries);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose a Doctor",
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal)),
                labelText: 'Search for a doctor',
              ),
              keyboardType: TextInputType.text,
              onChanged: (newValue) {
                _tx_search_filter = newValue;
                setState(() {});
              },
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: FutureBuilder<List<Map>>(
              future: getListDoctors(
                  _tx_search_filter), // This fetches the latest list
              builder: (context, snapshot) =>
                  _build_list_doctors(context, snapshot),
            )),
            ElevatedButton(
              onPressed: () async {
                await _addNewDoctor();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // Align content in the center
                children: [
                  Icon(Icons.add),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Add New",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColors.mainColor, // Background color
                foregroundColor: Colors.white, // Text color
                elevation: 5, // Shadow depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
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
                subtitle:
                    Text(_getSpecialtyNameById(items[index]['specialty_id'])),

                // Add trailing to show the delete icon
                trailing: IconButton(
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
                ),
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
