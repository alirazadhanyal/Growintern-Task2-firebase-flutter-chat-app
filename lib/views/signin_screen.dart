import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:say_hi/services/database_method.dart';
import 'package:say_hi/services/shared_prefrences.dart';
import 'package:say_hi/views/home_screen.dart';
import 'package:say_hi/views/signup_screen.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String name = "";
  String username = "";
  String profilePic = "";
  String userId = "";
  final _globalKey = GlobalKey<FormState>();
  final userEmailC = TextEditingController();
  final userPasswordC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                          MediaQuery.of(context).size.width, 105),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "SignIn",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Login to your account",
                          style: TextStyle(
                            fontSize: 22,
                            color: Color.fromARGB(255, 229, 229, 229),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.height / 1.5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Form(
                                key: _globalKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Email"),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Enter Email";
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller: userEmailC,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text("Password"),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                      ),
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Enter Password";
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller: userPasswordC,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.password),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: const Text(
                                        "forget password?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    InkWell(
                                      onTap: () {
                                        if (_globalKey.currentState!
                                            .validate()) {
                                          setState(() {});
                                        }
                                        userSignIn();
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.green,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.5),
                                                blurRadius: 5,
                                                offset: const Offset(1, 2),
                                              )
                                            ],
                                          ),
                                          child: const Text(
                                            textAlign: TextAlign.center,
                                            "SignIn",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpView(),
                            )),
                        child: const Text("Don't have an account? SignUp"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  userSignIn() async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmailC.text, password: userPasswordC.text);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserByEmail(userEmailC.text);

      name = "${querySnapshot.docs[0]["name"]}";
      username = "${querySnapshot.docs[0]["username"]}";
      profilePic = "${querySnapshot.docs[0]["profileUrl"]}";
      userId = "${querySnapshot.docs[0]["id"]}";

      await SharedPreferencesHelper().saveUserDisplayName(name);
      await SharedPreferencesHelper().saveUserNameKey(username);
      await SharedPreferencesHelper().savePicKey(profilePic);
      await SharedPreferencesHelper().saveUserId(userId);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Successfully Login")));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user found for that email.")));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Wrong password provided for that user.")));
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }
}
