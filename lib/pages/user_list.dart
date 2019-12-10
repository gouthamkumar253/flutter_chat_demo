import 'package:chat_app/pages/chat_screen.dart';
import 'package:chat_app/shared_preferences/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersList extends StatefulWidget {
  const UsersList({this.callback});

  final VoidCallback callback;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  String username;

  Future<void> initializeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final PreferencesClient preferencesClient = PreferencesClient(prefs: prefs);
    setState(() {
      username = preferencesClient.getUserName();
      print('Username from shared preference $username');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Users'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.assignment_return),
            onPressed: () {
              widget.callback();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            final List<DocumentSnapshot> items = snapshot.data.documents;
            items.removeWhere(
                (DocumentSnapshot snapshot) => snapshot.documentID == username);
            print(items.length);
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => ChatScreen(
                            sender: username,
                            receiver: items[index].documentID),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(items[index].documentID.split('@').first),
                        ),
                      ),
                    ),
                  );
                  return Container();
                });
          }
        },
      ),
    );
  }
}
