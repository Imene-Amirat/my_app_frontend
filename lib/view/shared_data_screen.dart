import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:get/route_manager.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedScreen extends StatefulWidget {
  final String recordId;
  SharedScreen({Key? key, required this.recordId}) : super(key: key);

  @override
  _SharedScreenState createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Returns the user ID, or null if not set
  }

  void _sendEmail() async {
    Dio dio = Dio();
    String apiEndpointSendEmail =
        "https://flask-app-medical.vercel.app/send_email";
    String emailContent = _emailController.text.trim();
    print(emailContent);
    String recordId = widget.recordId;
    String? user_Id = await getUserId();
    print(recordId);
    print(user_Id);

    if (emailContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an email address.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      FormData formData = FormData.fromMap({
        'email': emailContent,
        'record_id': recordId,
        'user_id': user_Id,
      });

      try {
        var response = await dio.post(apiEndpointSendEmail, data: formData);
        if (response.statusCode == 200) {
          // Handle success
          print('Email sent successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email sent successfully.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Handle server error
          print('Failed to send email: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send email.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } on DioError catch (e) {
        // Handle request error
        print('Error sending email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      // Clear the input field after sending the email
      _emailController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shared Screen",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left,
            size: 30,
          ),
          color: Colors.white,
        ),
        backgroundColor: GlobalColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
                'Enter the email of the person you want to share the record with:'),
            SizedBox(height: 10), // Add some space
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
