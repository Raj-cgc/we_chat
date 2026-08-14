import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self info
  static late ChatUser me;

  //to return current user
  static User get user {
    return auth.currentUser!;
  }

  //for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: "Hey whats up!",
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: user.uid,
      email: user.email.toString(),
      pushToken: ' ',
    );

    await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  //for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update user profile pic and also store in firebase storage
  static Future<void> updateUserProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    Reference ref = storage.ref().child('profilePictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
      p0,
    ) {
      log('Data Transferred : ${p0.bytesTransferred / 1000} kB');
    });

    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  /// ***********Chat Screen Related APIs*************

  //for getting conversation id
  static String getConversationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  //for getting all messages of a specific conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
    //message sending time used as uid
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      sent: time,
      fromId: user.uid,
    );

    final ref = firestore.collection(
      'chats/${getConversationID(chatUser.id)}/messages/',
    );

    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //for getting only last message of a conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
      'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
      p0,
    ) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    final isGroup = message.toId.startsWith('group_');

    if (isGroup) {
      await firestore
          .collection('groups/${message.toId}/messages')
          .doc(message.sent)
          .delete();
    } else {
      await firestore
          .collection('chats/${getConversationID(message.toId)}/messages/')
          .doc(message.sent)
          .delete();
    }

    if (message.type == Type.image) {
      try {
        await storage.refFromURL(message.msg).delete();
      } catch (e) {
        log('Error deleting image from storage: $e');
      }
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    final isGroup = message.toId.startsWith('group_');

    if (isGroup) {
      await firestore
          .collection('groups/${message.toId}/messages')
          .doc(message.sent)
          .update({'msg': updatedMsg});
    } else {
      await firestore
          .collection('chats/${getConversationID(message.toId)}/messages/')
          .doc(message.sent)
          .update({'msg': updatedMsg});
    }
  }

  /// *********** Group Chat Related APIs *************

  // create a new group with max 10 members
  static Future<void> createGroup(
      String groupName, List<ChatUser> selectedMembers) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final groupId = 'group_$time';

    final memberIds = [user.uid, ...selectedMembers.map((e) => e.id)];

    final groupData = {
      'id': groupId,
      'name': groupName,
      'image': '',
      'members': memberIds,
      'admin': user.uid,
      'createdAt': time,
      'lastMessage': 'Group created by ${me.name}',
      'lastMessageTime': time,
      'isGroup': true,
    };

    await firestore.collection('groups').doc(groupId).set(groupData);

    // Add initial system creation message inside group
    final initialMessage = Message(
      toId: groupId,
      msg: 'Group created by ${me.name}',
      read: time,
      type: Type.text,
      fromId: user.uid,
      sent: time,
    );

    await firestore
        .collection('groups/$groupId/messages')
        .doc(time)
        .set(initialMessage.toJson());
  }

  // stream of user groups
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups() {
    return firestore
        .collection('groups')
        .where('members', arrayContains: user.uid)
        .snapshots();
  }

  // stream of all messages in a group
  static Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessages(
      String groupId) {
    return firestore
        .collection('groups/$groupId/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // send group message
  static Future<void> sendGroupMessage(
      String groupId, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = Message(
      toId: groupId,
      msg: msg,
      read: '',
      type: type,
      fromId: user.uid,
      sent: time,
    );

    final ref = firestore.collection('groups/$groupId/messages');
    await ref.doc(time).set(message.toJson());

    // update group last message info
    await firestore.collection('groups').doc(groupId).update({
      'lastMessage': type == Type.text ? msg : '📷 Photo',
      'lastMessageTime': time,
    });
  }

  // send group chat image
  static Future<void> sendGroupImage(String groupId, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
      'group_images/$groupId/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageUrl = await ref.getDownloadURL();
    await sendGroupMessage(groupId, imageUrl, Type.image);
  }

  // leave a group
  static Future<void> leaveGroup(String groupId) async {
    await firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([user.uid]),
    });
  }

  // get specific group info stream
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getGroupInfo(
      String groupId) {
    return firestore.collection('groups').doc(groupId).snapshots();
  }

  // get group members users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMembers(
      List memberIds) {
    if (memberIds.isEmpty) {
      return firestore
          .collection('users')
          .where('id', isEqualTo: '')
          .snapshots();
    }
    return firestore
        .collection('users')
        .where('id', whereIn: memberIds.take(10).toList())
        .snapshots();
  }
}
