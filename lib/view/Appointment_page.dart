import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_app_frontend/components/button.dart';
import 'package:my_app_frontend/components/custom_appbar.dart';
import 'package:my_app_frontend/databases/DBAppointment.dart';
import 'package:my_app_frontend/utils/config.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/global_colors.dart';

class Appointment extends StatefulWidget {
  static final pageRoute = '/appointment';
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  //declaration
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Appointment',
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select Consultation Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      'Weekend is not available, please select another date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _timeSelected = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: _currentIndex == index
                                ? GlobalColors.mainColor
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentIndex == index ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Button(
                  width: double.infinity,
                  title: 'Make Appointment',
                  onPressed: () async {
                    if (_timeSelected && _dateSelected) {
                      // Conversion de _currentDay en String au format YYYY-MM-DD
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(_currentDay);

                      // Calcul de l'heure basé sur _currentIndex, ajout de 9 à l'index, et conversion en String
                      int hour = _currentIndex! +
                          9; // Cela donne l'heure en format 24 heures
                      String formattedTime =
                          "$hour:00"; // Convertit l'heure en String

                      try {
                        // Tentez d'insérer l'appointment dans la base de données
                        final int id = await DBAppointment.insertAppointment(
                            formattedDate, formattedTime);
                        print("Insertion réussie avec l'ID $id");

                        // Si l'insertion est réussie, naviguez vers la page de succès
                        Navigator.pushNamed(context, '/success_booked');
                      } catch (e) {
                        // En cas d'erreur lors de l'insertion, affichez une erreur à l'utilisateur
                        print("Erreur lors de l'insertion : $e");
                        // Ici, vous pourriez vouloir afficher une Snackbar ou une AlertDialog pour informer l'utilisateur
                      }
                    } else {
                      // Si la date ou l'heure n'est pas sélectionnée, informez l'utilisateur
                      // Encore une fois, une Snackbar ou une AlertDialog pourrait être utilisée ici
                      print("Veuillez sélectionner une date et une heure");
                    }
                  },
                  disable: _timeSelected && _dateSelected ? false : true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2024, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 45,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
            color: GlobalColors.mainColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          //check if weekend is selected
          if (selectedDay.weekday == 5 || selectedDay.weekday == 5) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}
