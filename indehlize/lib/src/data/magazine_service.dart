import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:indehlize/src/utils/Modals/magazineModel.dart';

class MagazineService {

  static List<magazineModel> myMagazines = [];


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _magazinesRef = FirebaseFirestore.instance.collection("magazines");

  // Singleton deseni uygula
  static MagazineService _singleton = MagazineService._internal();

  factory MagazineService() {
    return _singleton;
  }

  MagazineService._internal();

  static List<magazineModel> getMyMagazineList() {
    return myMagazines;
  }

  // Stream controller'ı kapatmak için bir metod tanımla
  void dispose() {
    // Burada streamController.close() çağrısına gerek yok, çünkü StreamController otomatik olarak kapatılır.
  }
}
