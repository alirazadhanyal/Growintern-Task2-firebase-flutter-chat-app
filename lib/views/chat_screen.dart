// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:say_hi/services/database_method.dart';
import 'package:say_hi/services/shared_prefrences.dart';

class ChatView extends StatefulWidget {
  ChatView({
    Key? key,
    required this.senderName,
    required this.senderProfile,
    required this.senderUserName,
  }) : super(key: key);

  final String senderName;
  final String senderProfile;
  final String senderUserName;

  final messageC = TextEditingController();

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String? myName, myUserName, myProfile, myEmail, messageId, chatRoomId;

  Stream? messageStream;

  getSharedPreferences() async {
    myName = await SharedPreferencesHelper().getUserDisplayName();
    myUserName = await SharedPreferencesHelper().getUserName();
    myProfile = await SharedPreferencesHelper().getUserPic();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    chatRoomId = getChatRoomIdByUsername(
      widget.senderUserName,
      myUserName!,
    );
    setState(() {});
  }

  onTheLoad() async {
    await getSharedPreferences();
    await getAndSetMessage();
    setState(() {});
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onTheLoad();
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: sendByMe ? Colors.green : Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30),
                  bottomLeft:
                      sendByMe ? const Radius.circular(30) : Radius.zero,
                  bottomRight:
                      sendByMe ? Radius.zero : const Radius.circular(30)),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: sendByMe ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                padding: const EdgeInsets.only(bottom: 90, top: 120),
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];

                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  addMessage(bool sendClicked) {
    if (widget.messageC.text != "") {
      String message = widget.messageC.text;
      widget.messageC.text = "";

      DateTime timeNow = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(timeNow);
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "timestamp": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imageUrl": myProfile,
      };

      messageId ??= randomAlphaNumeric(10);

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };

        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        title: Text(widget.senderName),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: DecorationImage(
                image: NetworkImage(widget.senderProfile),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.green[100],
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.12,
              padding: const EdgeInsets.all(8),
              child: chatMessages(),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: widget.messageC,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      hintText: "Write your message",
                      suffixIcon: InkWell(
                        onTap: () {
                          addMessage(true);
                          setState(() {});
                        },
                        child: const Icon(Icons.send),
                      ),
                    ),
                  ),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
