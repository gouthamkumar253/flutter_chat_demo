import 'package:chat_app/pages/user_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/login_signup_page.dart';
import 'package:chat_app/services/authentication.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  const RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = '';


  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((FirebaseUser user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    Map<String,dynamic> userInfo;

    widget.auth.getCurrentUser().then((FirebaseUser user) {
      print(user.toString());
      setState(() {
        _userId = user.email.toString();
        userInfo=<String,dynamic>{'user_id':_userId};
        authStatus = AuthStatus.LOGGED_IN;
        final DocumentReference documentReference = Firestore.instance
            .collection('users')
            .document(user.email);

        Firestore.instance.runTransaction((Transaction transaction) async {
          await transaction.set(
            documentReference,
            userInfo,
          );
        });

      });
    });

  }
  void logoutCallBack() async{
    await widget.auth.signOut();
    print('Logout called');
    setState(() {
      _userId='';
      authStatus=AuthStatus.NOT_LOGGED_IN;
    });
  }


  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return  LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId != null && _userId.isNotEmpty ) {
          return UsersList(
            username: _userId,
            uuid: _userId,
            callback: logoutCallBack,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
