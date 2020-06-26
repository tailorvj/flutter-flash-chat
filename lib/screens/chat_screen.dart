import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
String loggedInUserEmail;

class ChatScreen extends StatefulWidget {
  static String id = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  String messageText;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try{
      final user = await _auth.currentUser();
      if (user != null){
        loggedInUser = user;
        loggedInUserEmail = loggedInUser.email;
        print(loggedInUser.email);
      }
    } catch(e){
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for(var message in messages.documents){
  //     print(message.data);
  //   }
  // }

  // void messageStream() async{
  //   await for(var snapshot in _firestore.collection('messages').snapshots()){
  //     for(var message in snapshot.documents){
  //       print(message.data);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              // icon: Icon(Icons.exit_to_app),
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () {
                //Implement logout functionality
                try{
                  _auth.signOut();
                  Navigator.pop(context);
                  // getMessages();
                  // messageStream();
                } catch(e){
                  print(e);
                }
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text' : messageText,
                        'sender' : loggedInUser.email,
                        'timestamp' : DateTime.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot){
        List<MessageBubble> messageWidgets = [];
        if(snapshot.hasData){
          final messages = snapshot.data.documents;
          for(var message in messages){
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final messageTimestamp = message.data['timestamp'].toDate();
            
            final isMe = (messageSender == loggedInUserEmail);
            // print(isMe);

            final messageWidget = MessageBubble(
              text: messageText, 
              sender: messageSender,
              timestamp: messageTimestamp,
              isMe: isMe,
            );

            messageWidgets.add(messageWidget);
            messageWidgets.sort((a,b) => b.timestamp.compareTo(a.timestamp));
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageWidgets,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          ),
        );
      }
    );
  }
}

class MessageBubble extends StatelessWidget {

  final DateTime timestamp;
  final String text;
  final String sender;
  final bool isMe;

  MessageBubble({@required this.text, @required this.sender, this.isMe = false, this.timestamp,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            // borderRadius: BorderRadius.circular(30.0),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.0), 
              topLeft: isMe? Radius.circular(30.0) : Radius.circular(0),
              bottomRight: Radius.circular(30.0),
              topRight: isMe? Radius.circular(0) : Radius.circular(30.0),
              ),
            elevation: 5.0,
            // color: Colors.lightBlueAccent,
            color: isMe ? Colors.lightGreenAccent : Colors.lightBlueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                !isMe ?
                  (Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        sender,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                ) : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '$text',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '${timestamp.toString().substring(11).split('.')[0]}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );    
  }
}