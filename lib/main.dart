import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Login Test',
      theme: ThemeData( 
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  bool isLoggedIn = false;
  Map userProfile;
  final facebookLogin = FacebookLogin();
 

  _loginWithFB() async{
    final result = await facebookLogin.logIn(['email']);
    
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          isLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => isLoggedIn = false );
        break;
      case FacebookLoginStatus.error:
        setState(() => isLoggedIn = false );
        break;
    }

  }

  logout(){
    facebookLogin.logOut();
    setState(() {
      isLoggedIn = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoggedIn ? memberIsLogin() : memberNotLogin()
      )      
    );
  }

  OutlineButton memberIsLogin() {
    return OutlineButton(
      onPressed: logout,
      child: Text("Logout"),
    );
  }
  OutlineButton memberNotLogin(){
  return OutlineButton(
      onPressed: _loginWithFB,
      child: Text("Login to Facebook"),
    );
  }


}
