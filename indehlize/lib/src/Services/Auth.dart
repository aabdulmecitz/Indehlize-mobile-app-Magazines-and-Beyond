import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Auth with ChangeNotifier{
  final FirebaseAuth auth = FirebaseAuth.instance;
  //GoogleSignIn googleSignIn = GoogleSignIn();
  late User user;
  bool isSignIn = false;
  bool isNewUser = false;
  bool isGoogleUser = false;

  Future<bool> handleEmailSignUp(
      String email, String username, String password, String name, String surname, ) async {
    try {

      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      isSignIn = true;
      User? user = result.user;


      await FirebaseFirestore.instance.collection("Users").doc(user!.uid).set(
          {
            "userUid": result.user!.uid,
            "username" : username,
            "name": name,
            "surname": surname,
            "adress": "",
            "photo": "",
          }
      );
      notifyListeners();
      return true;
    }catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.red,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.deepPurple
      );
      return false;
    }
  }

  /*Future<bool> handleGoogleSignIn() async {
    var googleSignInAccount = await googleSignIn.signIn();
    var googleSignInAuth = await googleSignInAccount!.authentication;
    var credential =  GoogleAuthProvider.credential(
      idToken: googleSignInAuth.idToken,
      accessToken: googleSignInAuth.accessToken
    );

    var result = await auth.signInWithCredential(credential);
    user = result.user!;
    isSignIn = true;
    isGoogleUser = true;

    await FirebaseFirestore.instance
    .collection("Users").doc(credential.idToken).set(
      {
        "userId" : user.uid,
        "username" : user.displayName,
        "adress" : ""
      },
    );
    notifyListeners();

  }*/


  void toggleisSignIn(){
    isSignIn = !isSignIn;
    notifyListeners();
  }

  void toggleisNewUser(){
    isNewUser = !isNewUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    isSignIn = false;
    notifyListeners();
  }

 /* Future<void> googleSignOut() async{
    await auth.signOut().then((value) => {googleSignIn.signOut()});
    isSignIn = false;
    isGoogleUser = false;
    notifyListeners();
  }*/

  Future<User?> signInWhithEmailAndPassword(String email, String password) async{
    try{
      final UserCredential userCredential =
      await auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      Fluttertoast.showToast(
          msg: "You are logged in",
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.red,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.deepPurple
      );
      return userCredential.user;
    }catch(e){
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          textColor: Colors.red,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.deepPurple
      );
      /*if (code  == 'user-not-found') {
        // e maile kayıtlı kullanıcı yok
        Fluttertoast.showToast(
            msg: "Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }*/
      return null;
    }
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

}