import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static final pageRoute = '/home';
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getGreetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  Future<Map<String, String?>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');
    String? username = prefs.getString('user_username');
    print("Retrieved email: $email");
    print("Retrieved username: $username");

    return {
      'email': email,
      'username': username,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the back button
        flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            decoration: BoxDecoration(
              color: GlobalColors.mainColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, left: 15, right: 15, bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 6, left: 3, bottom: 5),
                          child: Text(
                            getGreetingMessage(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              wordSpacing: 2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.medical_information,
                          size: 30,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    FutureBuilder<Map<String, String?>>(
                      future: getUserDetails(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, String?>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, left: 10),
                                child: Text(
                                  "${snapshot.data!['username'] ?? 'No username'} 👋",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    wordSpacing: 2,
                                  ),
                                ));
                          } else {
                            return Text('Unable to fetch user details.');
                          }
                        } else {
                          // While the future is resolving, show a loading spinner
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    /*Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here.... ",
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(Icons.search, size: 25),
                        ),
                      ),
                    ),*/
                  ],
                )),
          );
        }),
        toolbarHeight: 109,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 0),
            child: Text(
              "Services",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black //GlobalColors.mainColor,
                  ),
            ),
          ),
          Container(
            height: 400, // Adjusted height to accommodate 2 rows of buttons
            child: GridView.count(
              crossAxisCount: 2, // Number of columns
              childAspectRatio: (1 / 1.1), // Adjust based on your child content
              crossAxisSpacing: 2, // Horizontal space between items
              mainAxisSpacing: 2, // Vertical space between items
              padding: EdgeInsets.all(10), // Padding around the grid
              physics:
                  NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              children: <Widget>[
                _buildButton(
                    'Medical \n Records',
                    LineAwesomeIcons.medical_notes,
                    GlobalColors.mainColor,
                    '/medicalRecords'),
                _buildButton('Family \n Members', Icons.family_restroom,
                    Colors.green, '/familyMembers'),
                _buildButton('Appointment', Iconsax.calendar_2, Colors.orange,
                    '/appointmentlist'),
                _buildButton('Doctors Directory', LineAwesomeIcons.stethoscope,
                    Colors.orange, '/doctors_directory'),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Today's Tasks",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String title, IconData iconData, Color color, String route) {
    final Color gradientStartColor =
        Color.fromRGBO(22, 72, 99, 1); // Start of gradient
    final Color gradientEndColor =
        Color.fromRGBO(58, 106, 145, 1); // End of gradient

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Card(
        elevation: 4.0, // Adjust elevation as needed
        shape: RoundedRectangleBorder(
          side: BorderSide(color: GlobalColors.mainColor, width: 1.0),
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0), //same borderCard
            /*gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientStartColor,
                gradientEndColor,
              ],
            ),*/
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15.0), // Same as Container
            onTap: () {
              Navigator.pushNamed(context, route);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Icon(iconData, size: 60, color: Colors.white),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromARGB(255, 5, 109, 173)
                        .withOpacity(0.1), // Transparent blue background
                  ),
                  child: Icon(
                    iconData,
                    color: Color.fromARGB(255, 5, 109, 173), // Blue icon color
                    size: 30, // Adjust the size as needed
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*Widget _buildButton(String title, IconData iconData /*String imagePath*/,
      Color color, String route) {
    final Color gradientStartColor = Color.fromRGBO(22, 72, 99, 1);
    // Start of gradient
    final Color gradientEndColor =
        Color.fromRGBO(58, 106, 145, 1); // End of gradient
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: 152,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientStartColor,
              gradientEndColor,
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent, // Make the material widget transparent
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0), // Same as Container
            onTap: () {
              Navigator.pushNamed(context, route);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Image.asset(
                  'assets/icons/$imagePath.png', // Adjust the path as per your project structure
                  width: 60,
                  height: 60,
                ),*/
                Icon(iconData, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    /*return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            minWidth: 155,
            height: 170,
            color: color,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/$imagePath.png', // Adjust the path as per your project structure
                  width: 60,
                  height: 60,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );*/
  }*/
}
