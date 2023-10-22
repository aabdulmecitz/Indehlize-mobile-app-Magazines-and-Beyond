import 'package:flutter/material.dart';

import '../../RegisterLogin/register/RegisterScreen.dart';

class goToDehliz extends StatefulWidget {
  const goToDehliz({Key? key}) : super(key: key);


  @override
  State<goToDehliz> createState() => _goToDehlizState();
}

class _goToDehlizState extends State<goToDehliz> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  late String password;
  late String email;

  @override
  Widget build(BuildContext context) {
    var displayInfo = MediaQuery.of(context).size;
    var displayHeight = displayInfo.height;
    var displayWidth = displayInfo.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: displayHeight/10,
                child: Image.asset('assets/logos/logo.png')),
            SizedBox(height: 20),
            Row(
                )
              ],
            ),
        ),
        /*child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.always,
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
                        if(value!.isEmpty){
                          return "Enter your email";
                        }else{
                          if (!isValidEmail(value)) {
                            return 'Please enter an email';
                          } else {
                            email = value;
                            return null;
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.always,
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
                        if(value!.isEmpty){
                          return "Enter your password";
                        }else{
                          return null;
                        }
                      },
                      onSaved: (value){
                        password = value!;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Text(
                              "Forgot My Password"
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _goToRegisterScreenButton()
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _loginButton(),
                  ],
                ),
              ),
            )
        ),*/
      );
  }

  Widget _loginButton() => ElevatedButton(
      onPressed: (){
        if (_formKey.currentState!.validate()){
          _formKey.currentState?.save();
          debugPrint("email = $email , password = $password");
          //  Auth().signInWithEmailAndPassword(email: email, password: password);
          //Go to main screen
        }
      },
      child: Text(
          "Login"
      )
  );

  Widget _goToRegisterScreenButton() => InkWell(
      onTap:() {navigateToScreen(context, RegisterScreen());},
      child: Text('Create Account')
  );

}

bool isValidEmail(String email) {
  final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}
