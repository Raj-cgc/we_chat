import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //another user's message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child:
                widget.message.type == Type.text
                    ? Text(
                      widget.message.msg,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    )
                    : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.message.msg),
                          fit: BoxFit.fill,
                        ),
                      ),
                      // backgroundImage: NetworkImage(widget.message.msg),
                      // radius: mq.height * 0.15,
                    ),
          ),
        ),

        //message time
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
              context: context,
              time: widget.message.sent,
            ),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  //our or current user's message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //add some space
            SizedBox(width: mq.width * 0.04),

            //add blue tick icon
            if (widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            //add some space
            SizedBox(width: mq.width * 0.01),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child:
                widget.message.type == Type.text
                    ? Text(
                      widget.message.msg,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    )
                    : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.message.msg),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView(
          //shrinkwrap allows to take only as much space as the contents in it
          shrinkWrap: true,
          children: [
            //divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.015,
                horizontal: mq.width * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            widget.message.type == Type.image
                ? OptionItem(
                  icon: Icon(Icons.download_rounded, color: Colors.blue),
                  name: 'Save Image',
                  onTap: () async {
                    await GallerySaver.saveImage(
                      widget.message.msg,
                      albumName: 'We Chat',
                    ).then((value) {
                      Navigator.of(context).pop();
                      Dialogs.showSnackbar(context, 'Image saved to Gallery');
                    });
                  },
                )
                : OptionItem(
                  icon: Icon(Icons.copy_all_rounded, color: Colors.blue),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.message.msg),
                    ).then((value) {
                      Navigator.pop(context);
                      Dialogs.showSnackbar(context, 'Text copied to clipboard');
                    });
                  },
                ),

            Divider(
              color: Colors.black54,
              endIndent: mq.width * 0.054,
              indent: mq.width * 0.054,
            ),

            if (widget.message.type == Type.text && isMe)
              OptionItem(
                icon: Icon(Icons.edit, color: Colors.blue),
                name: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 200), () {
                    _showMessageUpdateDialog(context);
                  });
                },
              ),

            if (isMe)
              OptionItem(
                icon: Icon(Icons.delete_forever, color: Colors.red),
                name: 'Delete Message',
                onTap: () {
                  APIs.deleteMessage(widget.message).then((value) {
                    Navigator.pop(context);
                  });
                },
              ),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.054,
                indent: mq.width * 0.054,
              ),
            OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.blue),
              name:
                  'Seen At:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              onTap: () {},
            ),
            OptionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.green),
              name:
                  widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  //dialog for updating message content
  void _showMessageUpdateDialog(final BuildContext context) {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            contentPadding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 10,
            ),

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),

            //title
            title: const Row(
              children: [
                Icon(Icons.message, color: Colors.blue, size: 28),
                Text(' Update Message'),
              ],
            ),

            //content
            content: TextFormField(
              initialValue: updatedMsg,
              maxLines: null,
              onChanged: (value) => updatedMsg = value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),

            //actions
            actions: [
              //cancel button
              MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),

              //update button
              MaterialButton(
                onPressed: () {
                  APIs.updateMessage(widget.message, updatedMsg);
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
}

//a common class to display all option items when we long press a message card
class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * 0.05,
          top: mq.height * 0.015,
          bottom: mq.height * 0.025,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '     $name',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
