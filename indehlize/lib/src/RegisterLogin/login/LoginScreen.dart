import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indehlize/src/RegisterLogin/register/RegisterScreen.dart';

import '../../Services/Auth.dart';
import '../../google_adds/google_adds.dart';
import '../../screens/MainScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  var login = false;
  late var email;
  late var password;
  late var validatePassword;


  final GoogleAdds _googleBannerAdd  = GoogleAdds();

  @override
  void initState() {
    super.initState();
    _googleBannerAdd.loadBannerAd(adLoaded: () {
      setState(() {
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    var displayInfo = MediaQuery.of(context);
    final double displayHeight = displayInfo.size.height;
    final double displayWidth = displayInfo.size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    indehlizeLogoImage(displayHeight),
                    SizedBox(
                      height: 50,
                    ),
                    buildEmail(),
                    SizedBox(
                      height: 20,
                    ),
                    buildPassword(),
                    SizedBox(
                      height: 20,
                    ),
                    _goTofotgottingPasswordTextButton(),
                    SizedBox(
                      height: 20,
                    ),
                    _goToRegisterScreenButton(),
                    SizedBox(
                      height: 20,
                    ),
                    _loginButton(),
                    SizedBox(
                      height: 50,
                    ),

                  ],
                ),
              ),
            ),
          )
      ),
      bottomNavigationBar: _googleBannerAdd.bannerAd == null
          ? Container()
          : screenBannerAdd(),
    );
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget indehlizeLogoImage(double displayHeight) => SizedBox(

      height: 100,
      child:
      SizedBox(height: displayHeight / 4,
          child: Image.asset('assets/logos/indehlizeblacklogo.png')),
  );

  Widget _loginButton() => ElevatedButton(
      onPressed: (){
        setState(() {
          if (_formKey.currentState!.validate()){
            _formKey.currentState!.save();
            debugPrint("email = $email , password = $password");
            Auth().signInWhithEmailAndPassword(email as String, password as String).onError((error, stackTrace)
            {
              Fluttertoast.showToast(
                  msg: error.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  textColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.deepPurple
              );
            });

            //Go to main screen
          }
        });

      },
      child: Text(
          "Login"
      )
  );

  Widget _goToRegisterScreenButton() => InkWell(
      onTap:() {navigateToScreen(context, RegisterScreen());},
      child: Text('Create Account')
  );

  Widget buildEmail() => TextFormField(
      key: ValueKey('email'),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.teal
            ),
          ),
          labelText: "Email",
          labelStyle: TextStyle(
            color: Colors.teal,
          ),
          border: OutlineInputBorder()
      ),
      validator: (value){
        if(value!.isEmpty || !isValidEmail(value.trim())){
          return "Please enter valid Email";
        }else{
          //email.text = value;
          return null;
        }
      },
      onSaved: (value){
        setState(() {
          email = value;
        });
      },
    );

  Widget buildPassword() => TextFormField(
      key: ValueKey('password'),
      obscureText: true,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.teal
            ),
          ),
          labelText: "Password",
          labelStyle: TextStyle(
            color: Colors.teal,
          ),
          border: OutlineInputBorder()
      ),
      validator: (value){
        if(value!.length < 6){
          return "Please Enter Password of min length 6";
        }else{
          return null;
        }
      },
      onSaved: (value){
        setState(() {
          password = value!;
        });;
      },
    );

  Widget _goTofotgottingPasswordTextButton() => GestureDetector(
    onTap: (){

    },
    child: Text(
          "Forgot My Password"
      ),
    );

  Widget screenBannerAdd(){
    return Container(
      child: _googleBannerAdd.bannerAd != null
          ? SizedBox(
        width: _googleBannerAdd.bannerAd!.size.width.toDouble(),
        height: _googleBannerAdd.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _googleBannerAdd.bannerAd!),
      )
          : Container(
        height: 50,
        width: double.maxFinite,
        color: Colors.blue,
      ),
    );
  }


}

