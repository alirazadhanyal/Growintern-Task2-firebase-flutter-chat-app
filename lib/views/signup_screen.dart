import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:say_hi/services/database_method.dart';
import 'package:say_hi/services/shared_prefrences.dart';
import 'package:say_hi/views/signin_screen.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  String userFullName = "";
  String userEmail = "";
  String userPassword = "";
  String userName = "";
  String userProfileUrl = "";

  final userEmailC = TextEditingController();
  final userPasswordC = TextEditingController();
  final userConfirmPasswordC = TextEditingController();
  final userNameC = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
                          "SignUp",
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
                          "Create New account",
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
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Name"),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                      ),
                                      child: TextFormField(
                                        controller: userNameC,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Name";
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
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
                                        controller: userEmailC,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter e-mail";
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.mail),
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
                                        controller: userPasswordC,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Password";
                                          } else {
                                            return null;
                                          }
                                        },
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.password),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    const Text("Retype Password"),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                      ),
                                      child: TextFormField(
                                        controller: userConfirmPasswordC,
                                        validator: (value) {
                                          if (userPasswordC.text !=
                                              userConfirmPasswordC.text) {
                                            return "Password Is Not Matched";
                                          } else {
                                            return null;
                                          }
                                        },
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          prefix: Icon(Icons.password),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Center(
                                        child: InkWell(
                                      onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignInView(),
                                          )),
                                      child: const Text(
                                          "Already have an account? SignIn"),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              userFullName = userNameC.text;
                              userEmail = userEmailC.text;
                              userPassword = userPasswordC.text;
                              userProfileUrl =
                                  "https://www.worldfuturecouncil.org/wp-content/uploads/2020/02/dummy-profile-pic-300x300-1-180x180.png";
                              userName =
                                  userEmailC.text.replaceAll("@gmail.com", "");
                            });
                          }
                          userSignUp();
                        },
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.5),
                                  blurRadius: 5,
                                  offset: const Offset(1, 2),
                                )
                              ],
                            ),
                            child: const Text(
                              textAlign: TextAlign.center,
                              "SignUp",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  userSignUp() async {
    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmailC.text,
        password: userPasswordC.text,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInView(),
          ));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully!")));

      String username = userEmailC.text.replaceAll("@gmail.com", "");
      String updatedUsername =
          username.replaceFirst(username[0], username[0].toUpperCase());
      String userFirstLetter = username.substring(0, 1).toUpperCase();
      String id = randomAlphaNumeric(10);
      Map<String, dynamic> userInfo = {
        "name": userNameC.text,
        "email": userEmailC.text,
        "username": updatedUsername.toUpperCase(),
        "firstLetter": userFirstLetter,
        "profileUrl":
            "https://scontent.fisb7-1.fna.fbcdn.net/v/t1.6435-9/95330316_3668474676498124_9178701104211296256_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=7a1959&_nc_eui2=AeEFRDWnzdKX5UfZ9fZffAqft93eEA8OK0S33d4QDw4rRKVPjpndtakcfSJffeCwzX1QR2d_k2UFVke5VX_t6qqf&_nc_ohc=Xodk_t1R_A0AX_MwvCa&_nc_oc=AQlfkUDZAoDdMm1jhF47RP1snhnw_1FYeyjYQkTewjehezH2SHxK6DNueTMsXaSxFeU&_nc_ht=scontent.fisb7-1.fna&oh=00_AfCkddjpYwnYQNiqM_QzV6OZuomie5zbzT1GMb6nL2tNdA&oe=660E92BE",
        "id": id,
      };

      await DatabaseMethods().addUserDetails(userInfo, id);
      await SharedPreferencesHelper().saveUserId(id);
      await SharedPreferencesHelper().saveUserDisplayName(userNameC.text);
      await SharedPreferencesHelper().saveUserNameKey(
          userEmailC.text.replaceAll("@gmail.com", "").toUpperCase());
      await SharedPreferencesHelper().saveEmailKey(userEmailC.text);
      await SharedPreferencesHelper().savePicKey(
          "https://www.worldfuturecouncil.org/wp-content/uploads/2020/02/dummy-profile-pic-300x300-1-180x180.png");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please Enter Strong Password. Use Alphanumeric")));
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email Already Register!")));
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
