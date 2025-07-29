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
    final time = DateTime.now().microsecondsSinceEpoch.toString();

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
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
