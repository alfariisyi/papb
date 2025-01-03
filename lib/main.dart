import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:papb/firebase_options.dart';
import 'package:papb/login.dart';
// import 'package:papb/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(MyApp());WidgetsFlutterBinding.ensureInitialized();
}
  

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Penyortiran Sampah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
