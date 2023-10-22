import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:indehlize/src/RegisterLogin/login/LoginScreen.dart';
import 'package:indehlize/src/Services/Auth.dart';
import 'package:indehlize/src/Services/User.dart';

import '../../Services/validator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{

  FirebaseFirestore db = FirebaseFirestore.instance;
  String? userUID;
  String? profilePicURL;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  var passwordController = TextEditingController();
  var usernameController =  TextEditingController();
  var emailController = TextEditingController();
  var verifiyPasswordController = TextEditingController();
  var nameController = TextEditingController();
  var lastnameController = TextEditingController();
  var phoneNumController = TextEditingController();

  var username;
  var email;
  var name;
  var lastname;
  var phoneNumber;
  var password;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Spacer(),
              Text("Register"),
              buildName(),
              buildLastName(),
              buildEmail(),
              buildUsername(),
              buildPhoneNum(),
              buildPassword(),
              buildValidationPassword(),
              SizedBox(height: 20),
              goToLoginScreen(),
              registerButton(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildName() => TextFormField(
    controller: nameController,
    decoration: InputDecoration(labelText: 'Name'),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Name cant be empty';
      }
      return null;
      },
    onSaved: (value) {
      name = value.toString();
    },
  );

  Widget buildLastName() => TextFormField(
    controller: lastnameController,
    decoration: InputDecoration(labelText: 'Lastname'),
    validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lastname cant be empty';
        }
        return null;
      },
    onSaved: (value) {
      lastname = value.toString();
      },
  );

  Widget buildEmail() => TextFormField(
    controller: emailController,
    decoration: InputDecoration(labelText: 'E-posta'),
    validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta boş olamaz';
        }
        return null;
      },
    onSaved: (value) {
      email = value.toString();
    },
    );

  Widget buildUsername() => TextFormField(
    controller: usernameController,
    decoration: InputDecoration(labelText: 'Username'),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Username boş olamaz';
      }
      return null;
      },
    onSaved: (value) {
      username = value.toString();
    },
    );

  Widget buildPhoneNum() => TextFormField(
    controller: phoneNumController,
    decoration: InputDecoration(labelText: 'Phone Number'),
    onSaved: (value) {
      phoneNumber = value.toString();
    },
    );

  Widget buildPassword() => TextFormField(
    controller: passwordController,
    decoration: InputDecoration(labelText: 'Şifre'),
    validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre boş olamaz';
        }
        return null;
      },
    obscureText: true,
    onSaved: (value) {
      password = value.toString();
    },
    );

  Widget buildValidationPassword() => TextFormField(
    controller: verifiyPasswordController,
    decoration: InputDecoration(labelText: 'Şifreyi tekrar giriniz'),
    validator: (value) {
      if (value.toString() != passwordController.value.text) {
        return 'Sifreler uyusmuyor';
      }
      return null;
    },
    obscureText: true,
  );

  Widget goToLoginScreen() => GestureDetector(
      child: Text("Do you have an account? Login"),
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => LoginScreen())),
    );

  Widget registerButton() => ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          Auth().handleEmailSignUp(email, username, password, name, lastname)
              .then((value) => Auth().signOut()).then((value) => Navigator.pop(context));
        }
      },
      child: Text('Kayıt Ol'),
    );



}
