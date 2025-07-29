import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 1,
      child: InkWell(
        onTap: () {
          //Navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              title: Text(widget.user.name),
              //last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'Image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
                style: TextStyle(
                  color:
                      _message != null && _message!.type == Type.image
                          ? Colors.blue
                          : Colors.black38,
                ),
              ),

              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.user.image),
                radius: mq.height * 0.028,
              ),

              //last message time
              trailing:
                  _message == null
                      ? null
                      : _message!.read.isEmpty &&
                          _message!.fromId != APIs.user.uid
                      ? Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                      : Text(
                        MyDateUtil.getLastMessageTime(
                          context: context,
                          time: _message!.sent,
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}
