import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/databases/DBAppointment.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/Appointment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';

class AppointmentPage extends StatefulWidget {
  static final pageRoute = '/appointmentlist';
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<List<Map<String, dynamic>>> _futureAppointments;
  String _userId = '';

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  Future<void> _updateAppointmentList() async {
    setState(() {
      _futureAppointments = DBAppointment.fetchAllAppointment(_userId);
    });
  }

  @override
  void initState() {
    super.initState();
    _futureAppointments = DBAppointment.fetchAllAppointment(_userId);
    _updateAppointmentList();
    getUserId().then((id) {
      _userId = id!;
      _updateAppointmentList(); // Now calls update without needing to pass userId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
          title: Text(
            'Appointment Schedule',
            style: TextStyle(
              // Rend le texte bold
              fontSize: 20, // Augmente la taille de la police si nécessaire
              // Vous pouvez également spécifier une famille de polices différente si vous le souhaitez
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          // Cela centre le titre sur l'appBar
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: GlobalColors.mainColor,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, Appointment.pageRoute).then((_) {
              _updateAppointmentList();
            });
          },
          //() => Get.to(() => Appointment()),
          icon: Icon(Icons.add),
          label: Text('Add New Appointment'),
        ),
        body: Column(
          children: [
            Config.spaceSmall,
            Expanded(
                child: FutureBuilder<List<Map>>(
              future: _futureAppointments,
              builder: (context, snapshot) =>
                  _buildAppointmentCard(context, snapshot),
            )
                /*ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/icons/inconnu.png'),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'rrrrrr',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'ggggggg',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ScheduleCard()
                          ],
                        ),
                      ));
                },
              ),*/
                ),
          ],
        ));
  }

  Widget _buildAppointmentCard(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }
      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
        List<Map> items = snapshot.data!;
        return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              String title = items[index]['title'] ?? 'No Title';
              return Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/icons/inconnu.png'),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Delete Appointment"),
                                        content: Text(
                                            "Are you sure you want to delete this Appointment?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Perform the deletion
                                              await DBAppointment
                                                  .deleteAppointment(
                                                      items[index]
                                                          ['Appointment_id']);
                                              print(items[index]
                                                  ['Appointment_id']);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Appointment deleted successfully!')));
                                              Navigator.of(context).pop();
                                              _updateAppointmentList(); // Refresh the list
                                            },
                                            child: Text("Delete"),
                                          )
                                        ],
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ScheduleCard(
                            date: items[index]['Date'] ?? 'No Date',
                            time: items[index]['Time'] ?? 'No Time'),
                      ],
                    ),
                  ));
            });
      } else {
        return Center(child: Text("No appointments found"));
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class ScheduleCard extends StatelessWidget {
  final String date;
  final String time;
  const ScheduleCard({
    Key? key,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 253, 252, 252),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Icon(
            Icons.calendar_today,
            color: Color.fromARGB(255, 0, 0, 3),
            size: 15,
          ),
          const SizedBox(
            width: 1,
          ),
          Text(
            date,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 10),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Icon(
            Icons.access_alarm,
            color: Colors.black,
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
            time,
            style: const TextStyle(
              color: Colors.black,
            ),
          ))
        ],
      ),
    );
  }
}
