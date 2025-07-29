import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/view_profile_screen.dart';
import 'package:we_chat/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  //controller for send message textfield
  final _textController = TextEditingController();

  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 172, 221, 246),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return SizedBox();

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list =
                            data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return (Center(
                            child: Text(
                              "Say Hi!!! 👋",
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

              if (_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16,
                    ),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              _chatInput(),

              if (_showEmoji)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        columns: 8,
                        backgroundColor: const Color.fromARGB(
                          255,
                          172,
                          221,
                          246,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //custom app bar widget
  Widget _appBar() {
    return Padding(
      padding: EdgeInsets.only(top: mq.height * 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewProfileScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                //back button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),

                //user profile pic
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    list.isNotEmpty ? list[0].image : widget.user.image,
                  ),
                  radius: mq.height * 0.028,
                ),

                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //user name
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      //Last seen status
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                          : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //Bottom Chat Input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * 0.01,
        horizontal: mq.width * 0.025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    //emoji button
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      ),
                    ),

                    //Textfield for message
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        //for text to go in mutliple lines on hitting enter
                        //or when space is over in one line
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          if (_showEmoji) {
                            setState(() => _showEmoji = !_showEmoji);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Type something...',
                          hintStyle: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    //Gallery button
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final List<XFile> images = await picker.pickMultiImage(
                          imageQuality: 80,
                        );

                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(Icons.image, color: Colors.blueAccent),
                    ),

                    //Camera button
                    IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                            widget.user,
                            File(image.path),
                          );
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Send button
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
