import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:indehlizei/pages/Login%20Signup/auth/auth.dart';

class User {
  late final String uuid;
  late final String password;
  late final String username;
  late final String email;
  late final String name;
  late final String lastname;
  late final String phoneNumber;

  User(this.uuid, this.password, this.username, this.email, this.name, this.lastname, this.phoneNumber);


}


