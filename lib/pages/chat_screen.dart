import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({this.sender, this.receiver});

  final String sender;
  final String receiver;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser user = ChatUser();
  String chatId;

  @override
  void initState() {
    user.name = widget.sender;
    user.uid=widget.sender;
    super.initState();
    chatId = widget.sender.compareTo(widget.receiver) > 0
        ? widget.sender + widget.receiver
        : widget.receiver + widget.sender;
  }

  void onSend(ChatMessage message) {
    print(message.toJson());
    final DocumentReference documentReference = Firestore.instance
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
  }

  void uploadFile() async {
    final File result = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 400,
      maxWidth: 400,
    );

    if (result != null) {
      final String id = Uuid().v4().toString();

      final StorageReference storageRef =
          FirebaseStorage.instance.ref().child('chat_images/$id.jpg');

      final StorageUploadTask uploadTask = storageRef.putFile(
        result,
        StorageMetadata(
          contentType: 'image/jpg',
        ),
      );
      final StorageTaskSnapshot download = await uploadTask.onComplete;

      final String url = await download.ref.getDownloadURL();

      final ChatMessage message = ChatMessage(text: '', user: user, image: url);

      final DocumentReference documentReference = Firestore.instance
          .collection('messages')
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.set(
          documentReference,
          message.toJson(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver.split('@').first),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('chats')
            .document(chatId)
            .collection('messages')
            .snapshots(),
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
            final List<ChatMessage> messages =
                items.map((dynamic i) => ChatMessage.fromJson(i.data)).toList();
            return SafeArea(
              child: DashChat(
                user: user,
                messages: messages,
                inputDecoration: InputDecoration(
                  hintText: 'Message here...',
                  border: InputBorder.none,
                ),
                onSend: onSend,
                trailing: <Widget>[
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: uploadFile,
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
