import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:say_hi/firebase_options.dart';
import 'package:say_hi/services/auth.dart';
import 'package:say_hi/views/home_screen.dart';
import 'package:say_hi/views/signin_screen.dart';
import 'package:say_hi/views/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final checkUser = FirebaseAuth.instance;

  isLogIn() {
    checkUser.authStateChanges().listen(
      (User? user) {
        if (user != null) {
          HomeScreen();
        }
        const SignInView();
      },
    );
    return const SignUpView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Say Hi! Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: AuthMethod().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return const SignInView();
            }
          },
        ));
  }
}
