import 'package:flutter/material.dart';
import 'package:flash_chat/components/material_button_with_padding.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool spin = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spin, 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 200.0,
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter your email'
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration: kInputDecoration.copyWith(
                  hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              MaterialButtonWithPadding(
                text: 'Log in',
                color: Colors.blueAccent,
                onPressed: () async {
                    setState((){
                      spin = true;
                    });
                  try{
                    final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                    if (newUser != null){
                      setState((){
                        spin = false;
                      });
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                  } catch(e){
                      setState((){
                        spin = false;
                      });
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
