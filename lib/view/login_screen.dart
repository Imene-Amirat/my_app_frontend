import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_frontend/main.dart';
import 'package:my_app_frontend/navigation.dart';
import 'package:my_app_frontend/utils/global_colors.dart';
import 'package:my_app_frontend/view/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  static final pageRoute = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  //bool varaible to show and hide password
  bool isVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  //func to signup the user
  /*Future<void> logIn() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        password: password.trim(),
        email: email.trim(),
      );
      //after a successful login should
      //save the username,email,id correctly during login process
      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('user_email', email);
        await prefs.setString('user_username',
            response.user!.userMetadata?['username'] ?? 'defaultUsername');
      }
      print("Saved email: $email");
      print("Saved email: ${response.user!.id}");
      print("Saved username: ${response.user!.userMetadata?['username']}");
    } on AuthException catch (e) {
      print(e);
    }
    if (!mounted) return;

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const MainNavigator()));
  }*/

  Future<void> logIn() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        password: password.trim(),
        email: email.trim(),
      );

      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('user_email', email);
        await prefs.setString('user_username',
            response.user!.userMetadata?['username'] ?? 'defaultUsername');

        // Navigate to the main navigator on successful login
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainNavigator()));
      } else {
        // If response.user is null, it could mean authentication failed.
        // Supabase should throw an error, which would be caught by the catch block below.
        print("Authentication failed. No user returned.");
      }
    } on AuthException catch (e) {
      // Handle authentication error
      // You might want to display an error message depending on e.message
      // For example:
      if (e.message.contains('Invalid login credentials')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Login Error'),
            content: Text('Invalid email or password.'),
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
            title: Text('Login Error'),
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
            Navigator.pop(
                context); //ferme l'écran actuel & retourne à l'écran précédent
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
                      "Login",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Login to your account",
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
                      }
                      return null;
                    },
                    onSaved: (value) => password = value ?? '',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(13),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _isLoading ? null : logIn,
                    color: GlobalColors.mainColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: GlobalColors.mainColor)
                        : const Text("LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            )),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot password ?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        //navigate to login
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 210, //hauteur de container fixe 210 px
                  //decoration est pour inclure image
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/login.png"),
                          fit: BoxFit.fitHeight)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
