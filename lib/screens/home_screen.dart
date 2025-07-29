import "dart:developer";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:we_chat/api/apis.dart";
import "package:we_chat/main.dart";
import "package:we_chat/models/chat_user.dart";
import "package:we_chat/screens/profile_screen.dart";
import "package:we_chat/widgets/chat_user_card.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for setting user status to active first time when app loads
    APIs.updateActiveStatus(true);

    //for updating user active status according to lifecycle events
    //resume --> app opened --> active or online
    //pause --> app closed --> inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      //if pressed back button on search then come to home...
      //or else simply back
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home_rounded),
            title:
                _isSearching
                    ? TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search a user...',
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 1),
                      onChanged: (value) {
                        //search logic
                        _searchList.clear();

                        for (var i in _list) {
                          if (i.name.toLowerCase().contains(
                                value.toLowerCase(),
                              ) ||
                              i.email.toLowerCase().contains(
                                value.toLowerCase(),
                              )) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                    : Text('We Chat'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: APIs.me),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),

          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                      [];

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _searchList.length : _list.length,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: mq.height * 0.01),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user:
                              _isSearching ? _searchList[index] : _list[index],
                        );
                        // return Text('Name : ${list[index]}');
                      },
                    );
                  } else {
                    return (Center(
                      child: Text(
                        "No Connections Found !",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
