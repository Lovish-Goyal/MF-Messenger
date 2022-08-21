import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Models/firebasehelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'pages/LoginPage.dart';
import 'pages/homepage.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentuser = FirebaseAuth.instance.currentUser;
  if (currentuser != null) {
    UserModel? thisuserModel =
        await FirebaseHelper.getUserModelById(currentuser.uid);
    if (thisuserModel != null) {
      runApp(MyAppLoggedIn(
        userModel: thisuserModel,
        firebaseuser: currentuser,
      ));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseuser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseuser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
        usermodel: userModel,
        firebaseuser: firebaseuser,
      ),
    );
  }
}
