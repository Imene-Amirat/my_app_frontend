import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_app_frontend/main.dart';
import 'package:my_app_frontend/navigation.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';

class SignUpScreen extends StatefulWidget {
  static final pageRoute = '/sign';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String email = '';
  String password = '';
  String username = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  //func to signup the user
  /*Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await supabase.auth.signUp(
          password: password.trim(),
          email: email.trim(),
          data: {'username': username.trim()});
      if (result.user != null) {
        // Save email, username, and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_username', username);
        await prefs.setString(
            'user_id', result.user!.id); // Ensure the user object is not null

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainNavigator()));
      } /*else {
      print("Sign-up failed: ${result.error?.message}");
    }*/
    } on AuthException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const MainNavigator()));
  }*/

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await supabase.auth.signUp(
          password: password.trim(),
          email: email.trim(),
          data: {'username': username.trim()});
      if (result.user != null) {
        // Save email, username, and user ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_username', username);
        await prefs.setString(
            'user_id', result.user!.id); // Ensure the user object is not null

        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainNavigator()));
      } else {
        print("Authentication failed. No user returned.");
      }
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('the email is already in use.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } else {
        // Handle other types of AuthExceptions
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
      print(e.message);
    } finally {
      // Always stop the loading indicator, regardless of the outcome
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            //removes the top route from the stack
            //remove the current screen and go back to the previous screen
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: GlobalColors.mainColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Column(
                  children: [
                    Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Register new account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 97, 97, 97),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(13.0),
                  child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 164, 163, 163)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: GlobalColors.mainColor.withOpacity(0.8)),
                        ),
                        hintStyle: TextStyle(
                            fontSize: 13.0, color: Colors.blueGrey.shade300),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value ?? ''),
                ),
                Padding(
                  padding: EdgeInsets.all(13.0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 164, 163, 163)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: GlobalColors.mainColor.withOpacity(0.8)),
                      ),
                      hintStyle: TextStyle(
                          fontSize: 13.0, color: Colors.blueGrey.shade300),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) => password = value ?? '',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(13.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 164, 163, 163)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: GlobalColors.mainColor.withOpacity(0.8)),
                      ),
                      hintStyle: TextStyle(
                          fontSize: 13.0, color: Colors.blueGrey.shade300),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                    onSaved: (value) => username = value ?? '',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(13),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _isLoading ? null : signUp,
                    color: GlobalColors.mainColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: GlobalColors.mainColor)
                        : const Text("Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            )),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        //navigate to login
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
