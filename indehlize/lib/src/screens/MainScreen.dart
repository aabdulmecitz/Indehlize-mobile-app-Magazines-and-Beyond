import 'package:flutter/material.dart';
import '../Services/Auth.dart';
import 'DrawerScreens/AboutScreen.dart';
import 'DrawerScreens/AddMagazineScreen.dart';
import 'DrawerScreens/HomeScreen.dart';
import 'DrawerScreens/MyLibraryScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Auth _auth = Auth();
  var username = "owner";
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isSearchOpen = false;
  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    var displayInfo = MediaQuery.of(context).size;
    var displayHeight = displayInfo.height;
    var displayWidth = displayInfo.width;



    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer(displayHeight.toInt(), displayWidth.toInt()),
      body: HomeScreen(),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop(); // Drawer'ı kapatır
  }


  Widget signOutTextButton() => Padding(
      padding: const EdgeInsets.all(30.0),
      child: GestureDetector(
        onTap: () => setState(() {
          Auth().signOut();
        }),// Sign out işlevi
        child: Row(
          children: <Widget>[
            Icon(
              Icons.cancel,
              color: Colors.blueGrey.withOpacity(0.5),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Sign Out',
              style: TextStyle(color: Colors.blueGrey.withOpacity(0.5)
              ),
            )
          ],
        ),
      ),
    );

  Widget drawer(int displayHeight, int displayWidth) => Drawer(
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white,
              ]
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white
                      ]
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: displayHeight / 8,
                        child: Image.asset('assets/logos/indehlizeblacklogo.png')),
                    SizedBox(height: 20),
                  /*  Row(
                      children: [
                        SizedBox(width: 10),
                        CircleAvatar(),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ahmet Abdulmecit zky',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                                '@$username',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)
                            )
                          ],
                        )
                      ],
                    ),*/
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  NewRow(
                      text: 'Home',
                      icon: Icons.home_outlined,
                      onTap: () => {
                        _closeDrawer()
                      }
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NewRow(
                      text: 'Add Magazine',
                      icon: Icons.library_add_outlined,
                      onTap: () => {
                        navigateToScreen(context, AddMagazineScreen()),
                      }
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NewRow(
                    text: 'My Library',
                    icon: Icons.local_library_outlined,
                    onTap: (){
                      navigateToScreen(
                          context, MyLibraryScreen()
                      );
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  /*
                  NewRow(
                    text: 'Saved',
                    icon: Icons.bookmark_border,
                    onTap: (){
                      navigateToScreen(context, SavedScreen());
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NewRow(
                    text: 'Favorites',
                    icon: Icons.favorite_border,
                    onTap: (){
                      navigateToScreen(context, FavoritesScreen());
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  NewRow(
                    text: 'Hint',
                    icon: Icons.lightbulb_outline,
                    onTap: (){
                      navigateToScreen(context, HintScreen());
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),*/
                  NewRow(
                    text: 'About',
                    icon: Icons.info_outline_rounded,
                    onTap: (){
                      navigateToScreen(context, AboutScreen());
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
               /*   NewRow(
                    text: 'FAQ',
                    icon: Icons.question_answer_outlined,
                    onTap: (){
                      navigateToScreen(context, FAQScreen());
                    },

                  ),
                  SizedBox(
                    height: 20,
                  ),*/
                ],
              ),
            ),
            SizedBox(height: 20),
            Spacer(flex: 100),
            signOutTextButton(),
            SizedBox(
                height: 20),

          ],
        ),
      ),
    );

}



void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
}

class NewRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? onTap;

  const NewRow({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.blueGrey,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.blueGrey),
          )
        ],
      ),
    );
  }
}
