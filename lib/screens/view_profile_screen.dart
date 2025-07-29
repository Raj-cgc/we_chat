import "package:flutter/material.dart";
import "package:we_chat/helper/my_date_util.dart";
import "package:we_chat/main.dart";
import "package:we_chat/models/chat_user.dart";

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

//view profile screen of other users
class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard on pressing anywhere on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.user.name)),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On: ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),

        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: mq.height * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  //else use the default photo from networkImage
                  backgroundImage: NetworkImage(widget.user.image),
                  radius: mq.height * 0.11,
                ),

                SizedBox(height: mq.height * 0.03),

                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),

                SizedBox(height: mq.height * 0.02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      widget.user.about,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
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
