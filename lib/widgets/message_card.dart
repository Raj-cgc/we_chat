import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:we_chat/api/apis.dart';
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

  // received message (another user)
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.text ? 14 : 6),
                margin: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.04,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F212E),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          height: mq.height * 0.28,
                          width: mq.width * 0.55,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFA855F7),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                            color: Colors.white30,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: mq.width * 0.06, bottom: 6),
          child: Text(
            MyDateUtil.getFormattedTime(
              context: context,
              time: widget.message.sent,
            ),
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }

  // sent message (current user)
  Widget _greenMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.text ? 14 : 6),
                margin: EdgeInsets.symmetric(
                  horizontal: mq.width * 0.04,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          height: mq.height * 0.28,
                          width: mq.width * 0.55,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                            color: Colors.white30,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.06, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.message.read.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.done_all_rounded,
                      color: Color(0xFFA855F7), size: 16),
                ),
              Text(
                MyDateUtil.getFormattedTime(
                  context: context,
                  time: widget.message.sent,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E202D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (modalContext) {
        final parentMessenger = ScaffoldMessenger.of(context);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: mq.height * 0.015),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // 1. Copy Text (for Text) OR Save Image (for Image)
              if (widget.message.type == Type.text)
                ListTile(
                  leading: const Icon(Icons.copy_all_rounded,
                      color: Color(0xFFA855F7), size: 26),
                  title: const Text('Copy Text',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    await Clipboard.setData(
                        ClipboardData(text: widget.message.msg));
                    parentMessenger.clearSnackBars();
                    parentMessenger.showSnackBar(
                      const SnackBar(
                        content: Text("Text Copied! 📋"),
                        backgroundColor: Color(0xFF9333EA),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down_to_line,
                      color: Color(0xFFA855F7), size: 26),
                  title: const Text('Save Image',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () async {
                    Navigator.pop(modalContext);

                    parentMessenger.clearSnackBars();
                    parentMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Saving Image to We Chat folder...'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    try {
                      final hasAccess = await Gal.hasAccess();
                      if (!hasAccess) {
                        final granted = await Gal.requestAccess();
                        if (!granted) {
                          parentMessenger.clearSnackBars();
                          parentMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Gallery Permission Denied!'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                      }

                      log('Retrieving image from cache: ${widget.message.msg}');
                      final file = await DefaultCacheManager()
                          .getSingleFile(widget.message.msg);

                      log('Found cached file (${await file.length()} bytes): ${file.path}');

                      await Gal.putImage(
                        file.path,
                        album: 'We Chat',
                      );

                      log('Successfully saved cached image to We Chat album via Gal');

                      parentMessenger.clearSnackBars();
                      parentMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Image Saved to We Chat folder! 🖼️'),
                          backgroundColor: Color(0xFF9333EA),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      log('Error Saving Image from cache: $e');
                      parentMessenger.clearSnackBars();
                      parentMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to Save Image: $e'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),

              // 2. Edit Message (Only for text & sender)
              if (widget.message.type == Type.text && isMe)
                ListTile(
                  leading: const Icon(Icons.edit_rounded,
                      color: Colors.blueAccent, size: 26),
                  title: const Text('Edit Message',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _showMessageUpdateDialog();
                  },
                ),

              // 3. Delete Message (Only for sender)
              if (isMe)
                ListTile(
                  leading: const Icon(CupertinoIcons.trash,
                      color: Colors.redAccent, size: 24),
                  title: const Text('Delete Message',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    try {
                      await APIs.deleteMessage(widget.message);
                      parentMessenger.clearSnackBars();
                      parentMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("Message Deleted! 🗑️"),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      log('Error deleting message: $e');
                      parentMessenger.clearSnackBars();
                      parentMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("Message Deleted! 🗑️"),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),

              Divider(
                color: Colors.white.withValues(alpha: 0.1),
                indent: mq.width * 0.05,
                endIndent: mq.width * 0.05,
              ),

              // 4. Sent Time
              ListTile(
                leading: const Icon(Icons.remove_red_eye_rounded,
                    color: Colors.white54, size: 24),
                title: Text(
                  'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              // 5. Read Time
              ListTile(
                leading: const Icon(Icons.done_all_rounded,
                    color: Color(0xFFA855F7), size: 24),
                title: Text(
                  widget.message.read.isEmpty
                      ? 'Read At: Not read yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1D2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFFA855F7)),
            SizedBox(width: 10),
            Text(
              "Update Message",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF242636),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9333EA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
