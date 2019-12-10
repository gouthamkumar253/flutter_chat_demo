import 'package:chat_app/pages/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  const UsersList({this.username, this.uuid, this.callback});

  final String username;
  final String uuid;
  final VoidCallback callback;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
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

            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  if (items[index].documentID != widget.username)
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute<Widget>(
                          builder: (BuildContext context) => ChatScreen(
                              sender: widget.username,
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
                            title:
                                Text(items[index].documentID.split('@').first),
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
