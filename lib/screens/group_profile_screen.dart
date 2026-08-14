import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';

class GroupProfileScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const GroupProfileScreen({super.key, required this.groupData});

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    final String groupId = widget.groupData['id'] ?? '';
    final String groupName = widget.groupData['name'] ?? 'Group';
    final String createdAt = widget.groupData['createdAt'] ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF13141C), Color(0xFF0D0E15)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: APIs.getGroupInfo(groupId),
            builder: (context, snapshot) {
              final gData = snapshot.data?.data() ?? widget.groupData;
              final List members = gData['members'] ?? [];
              final String adminId = gData['admin'] ?? '';

              return Column(
                children: [
                  // App Bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF242636)
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.chevron_left,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          "Group Info",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Group Avatar Icon
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFA855F7),
                                    Color(0xFF7C3AED)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C3AED)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.group_solid,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Group Name
                          Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Created At Date
                          Text(
                            createdAt.isNotEmpty
                                ? "Created at ${MyDateUtil.getLastMessageTime(context: context, time: createdAt, showYear: true)}"
                                : "Group Chat",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Members Section Header
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${members.length} Members",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Group Members List
                          StreamBuilder(
                            stream: APIs.getGroupMembers(members),
                            builder: (context, memberSnapshot) {
                              if (!memberSnapshot.hasData) {
                                return const CircularProgressIndicator(
                                  color: Color(0xFFA855F7),
                                );
                              }

                              final memberDocs =
                                  memberSnapshot.data?.docs ?? [];
                              final memberUsers = memberDocs
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .toList();

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: memberUsers.length,
                                itemBuilder: (context, index) {
                                  final member = memberUsers[index];
                                  final isAdmin = member.id == adminId;
                                  final isMe = member.id == APIs.user.uid;

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B1D2A),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          imageUrl: member.image,
                                          errorWidget:
                                              (context, url, error) =>
                                                  CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color(0xFF7C3AED),
                                            child: Text(
                                              member.name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        isMe ? "${member.name} (You)" : member.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      subtitle: Text(
                                        member.about,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: isAdmin
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFA855F7)
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFFA855F7),
                                                ),
                                              ),
                                              child: const Text(
                                                "Admin",
                                                style: TextStyle(
                                                  color: Color(0xFFA855F7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Leave Group Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.redAccent.withValues(alpha: 0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                      color: Colors.redAccent, width: 1.5),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _confirmLeaveGroup(context, groupId),
                              icon: const Icon(
                                CupertinoIcons.square_arrow_right,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                "Leave Group",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmLeaveGroup(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1D2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Row(
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle,
                color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              "Leave Group",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to leave this group?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final dialogNav = Navigator.of(context);
              dialogNav.pop(); // Close confirm dialog
              await APIs.leaveGroup(groupId);
              if (mounted) {
                Navigator.of(this.context).popUntil((route) => route.isFirst);
                Dialogs.showSnackbar(this.context, "You left the group.");
              }
            },
            child: const Text(
              "Leave",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
