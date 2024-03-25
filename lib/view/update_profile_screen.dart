import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_app_frontend/main.dart';
import 'package:my_app_frontend/utils/global_colors.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  const UpdateProfileScreen({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController fullnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  final ImagePicker imagePicker = ImagePicker();
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the passed values.
    fullnameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    phoneController =
        TextEditingController(); // If you have initial values for phone, set it here
    passwordController =
        TextEditingController(); // If you have initial values for password, set it here
  }

  @override
  void dispose() {
    // Don't forget to dispose the controllers when the widget is removed from the widget tree.
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              LineAwesomeIcons.angle_left,
              color: Colors.white,
            )),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
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
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    controller: fullnameController,
                    decoration: InputDecoration(
                      label: Text("Full Name"),
                      prefixIcon: Icon(LineAwesomeIcons.user),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      label: Text("E-Mail"),
                      prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      label: Text("Phone No"),
                      prefixIcon: Icon(LineAwesomeIcons.phone),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColors.mainColor,
                          shape: const StadiumBorder(),
                        ),
                      )),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
