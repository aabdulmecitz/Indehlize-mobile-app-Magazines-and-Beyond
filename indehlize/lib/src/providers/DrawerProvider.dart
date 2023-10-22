import 'package:flutter/material.dart';

class DrawerProvider extends ChangeNotifier{

  int drawerIndex = 0;

  int readDrawerIndex(){
    return drawerIndex;
  }

  void selectedIndex(int newIndex){
    drawerIndex = newIndex;
    notifyListeners();
  }

}