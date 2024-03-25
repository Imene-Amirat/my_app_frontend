import 'package:lottie/lottie.dart';
import 'package:my_app_frontend/components/button.dart';
import 'package:flutter/material.dart';

class AppointmentBooked extends StatelessWidget {
  static final pageRoute = 'success_booked';
  const AppointmentBooked({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Lottie.asset('assets/icons/Successfully_Done2.json'),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                'Successfully Booked',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            //back to home page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Button(
                width: double.infinity,
                title: 'Appointment Schedule',
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName('/appointmentlist')),
                disable: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}
