import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/main.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/login_screen.dart';
import 'package:my_app_frontend/view/update_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  static final pageRoute = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProfileScreen> {
  final ImagePicker imagePicker = ImagePicker();
  XFile? imageFile;
  String? _imageURL;

  void _pickImage(ImageSource source) async {
    // If the source is the camera, continue allowing only single image selection
    if (source == ImageSource.camera) {
      final XFile? selectedImage = await imagePicker.pickImage(source: source);
      if (selectedImage != null) {
        setState(() {
          imageFile = selectedImage;
        });
      }
    } else {
      // For the gallery, allow multiple image selections
      final XFile? selectedImage = await imagePicker.pickImage(source: source);
      if (selectedImage != null) {
        setState(() {
          imageFile = selectedImage;
        });
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    //adding a new route (the bottom sheet) on top of the current screen
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context)
                        .pop(); //remove this route (close the bottom sheet)
                  }),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  // it uses the exact keys i used to save the data in log
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

  Future<void> getUserDetailsAndNavigatetoUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');
    String? username = prefs.getString('user_username');

    // Navigate to UpdateProfileScreen with user details
    if (username != null && email != null) {
      Get.to(() => UpdateProfileScreen(username: username, email: email));
    } else {
      // Handle the case where username or email is not found
      print('No user details available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: GlobalColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon,
                color: Colors.white,
                size: 30,
              )), //isDark? if it's true is dark : else
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: imageFile != null
                          ? FileImage(File(imageFile!.path))
                          : AssetImage('assets/icons/inconnu.png')
                              as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: GlobalColors.mainColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              FutureBuilder<Map<String, String?>>(
                future: getUserDetails(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, String?>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Text(
                            snapshot.data!['username'] ??
                                'No username', // Display the username
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          SizedBox(height: 10),
                          Text(
                            snapshot.data!['email'] ??
                                'No email', // Display the email
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          // Continue with the rest of your widget tree
                        ],
                      );
                    } else {
                      return Text('Unable to fetch user details.');
                    }
                  } else {
                    // While the future is resolving, show a loading spinner
                    return CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      getUserDetailsAndNavigatetoUpdate();
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalColors.mainColor,
                      shape: const StadiumBorder(),
                    ),
                  )),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              //menu
              /*ProfileMenuWidget(
                title: 'Settings',
                icon: LineAwesomeIcons.cog,
                onPress: () {},
              ),*/
              /*ProfileMenuWidget(
                title: 'Billing Details',
                icon: LineAwesomeIcons.wallet,
                onPress: () {},
              ),*/
              /*ProfileMenuWidget(
                title: 'User Management',
                icon: LineAwesomeIcons.user_check,
                onPress: () {},
              ),*/
              //const Divider(),
              /*const SizedBox(
                height: 10,
              ),*/
              ProfileMenuWidget(
                title: 'Information',
                icon: LineAwesomeIcons.info,
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: 'Logout',
                icon: LineAwesomeIcons.alternate_sign_out,
                textColor: Colors.red,
                endIcon: false,
                onPress: () {
                  signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onPress,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Color.fromARGB(255, 5, 109, 173).withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Color.fromARGB(255, 5, 109, 173),
          ),
        ),
        title: Text(title,
            style:
                Theme.of(context).textTheme.bodyText1?.apply(color: textColor)),
        trailing: endIcon
            ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: const Icon(
                  LineAwesomeIcons.angle_right,
                  size: 18.0,
                  color: Colors.grey,
                ),
              )
            : null);
  }
}
