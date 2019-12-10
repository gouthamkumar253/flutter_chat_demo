import 'package:flutter/material.dart';
import 'package:chat_app/services/authentication.dart';
import 'package:chat_app/pages/root_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme:  ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:  RootPage(auth:  Auth()));
  }
}
