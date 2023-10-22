import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices{
  static saveUser(String name, String surname, String username, String email) async{
    await FirebaseFirestore.instance
        .collection("users")
        .doc("uid")
        .set({
      'email' : email,
      "name" : name,
    });
  }
}



// This gonna be correct for saving on firestore