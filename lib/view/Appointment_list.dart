import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/Appointment_page.dart';

import '../utils/config.dart';

class AppointmentPage extends StatefulWidget {
  static final pageRoute = '/appointmentlist';
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
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
          onPressed: () => Get.to(() => Appointment()),
          icon: Icon(Icons.add),
          label: Text('Add New Appointment'),
        ),
        body: Column(
          children: [
            Config.spaceSmall,
            Expanded(
              child: ListView.builder(
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
              ),
            ),
          ],
        ));
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key}) : super(key: key);

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
            width: 5,
          ),
          Text(
            'Monday , 11/28/2022',
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 10),
            ),
          ),
          const SizedBox(
            width: 20,
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
            '2:00 PM',
            style: const TextStyle(
              color: Colors.black,
            ),
          ))
        ],
      ),
    );
  }
}
