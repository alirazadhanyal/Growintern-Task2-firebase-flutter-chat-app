import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:say_hi/services/database_method.dart';
import 'package:say_hi/services/shared_prefrences.dart';
import 'package:say_hi/views/chat_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  String senderName = "Name";
  String senderProfile =
      "https://www.worldfuturecouncil.org/wp-content/uploads/2020/02/dummy-profile-pic-300x300-1-180x180.png";
  String senderMessage = "your message";
  String sendTime = "8:17 PM";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearch = false;

  var queryResultSet = [];
  var tempSearchStore = [];

  String? myName, myProfilePic, myUsername, myEmail;

  Stream? chatRoomStream;

  getTheSharedPreferences() async {
    myName = await SharedPreferencesHelper().getUserDisplayName();
    myProfilePic = await SharedPreferencesHelper().getUserPic();
    myUsername = await SharedPreferencesHelper().getUserName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    setState(() {});
  }

  onTheLoad() async {
    await getTheSharedPreferences();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      isSearch = true;
    });
    var capitalizeValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().searchUser(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; i++) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element["username"].startsWith(capitalizeValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isSearch
                ? Expanded(
                    child: TextField(
                      onChanged: (value) {
                        initiateSearch(value.toUpperCase());
                      },
                      decoration: const InputDecoration(
                          hintText: "Search User",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          )),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const Text("Chat"),
            InkWell(
              onTap: () {
                setState(() {});
                isSearch = !isSearch;
              },
              child:
                  isSearch ? const Icon(Icons.close) : const Icon(Icons.search),
            ),
          ],
        ),
      ),
      body: isSearch
          ? Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 10, right: 10),
                primary: false,
                shrinkWrap: true,
                children: tempSearchStore.map(
                  (e) {
                    return buildResultCard(e);
                  },
                ).toList(),
              ),
            )
          : chatRoomList(),
    );
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                      lastMessage: ds["lastMessage"],
                      chatRoomId: ds.id,
                      myUsername: myUsername!,
                      time: ds["lastMessageSendTs"]);
                },
              )
            : const Center(
                child: Text("No Chats Available"),
              );
      },
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        isSearch = false;
        setState(() {});
        var chatRoomId = getChatRoomIdByUsername(myUsername!, data["username"]);
        Map<String, dynamic> chatRoomInfoMap = {
          "user": [
            myUsername,
            data["username"],
          ]
        };
        await DatabaseMethods().createAChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                  senderName: data["name"],
                  senderProfile: data["profileUrl"],
                  senderUserName: data["username"]),
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    data["profileUrl"],
                    height: 70,
                    width: 70,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data["username"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile({
    super.key,
    required this.lastMessage,
    required this.chatRoomId,
    required this.myUsername,
    required this.time,
  });

  final String lastMessage, chatRoomId, myUsername, time;

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicture = "", name = "", id = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicture = "${querySnapshot.docs[0]["profileUrl"]}";
    id = "${querySnapshot.docs[0]["id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                senderName: name,
                senderProfile: profilePicture,
                senderUserName: username,
              ),
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Material(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: profilePicture == ""
                      ? const CircularProgressIndicator()
                      : Image.network(
                          profilePicture,
                          width: 70,
                          height: 70,
                        ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.lastMessage,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
