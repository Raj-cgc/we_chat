import "dart:developer";
import "dart:io";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:image_picker/image_picker.dart";
import "package:we_chat/api/apis.dart";
import "package:we_chat/helper/dialogs.dart";
import "package:we_chat/main.dart";
import "package:we_chat/models/chat_user.dart";
import "package:we_chat/provider/auth_provider.dart";
import "package:we_chat/screens/auth/login_screen.dart";

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  _handleLogoutBtnClick() async {
    Dialogs.showProgressBar(context);
    APIs.updateActiveStatus(false);

    await AutProvider.signOut().then((value) async {
      if (mounted) Navigator.pop(context);
      if (mounted) Navigator.pop(context);

      APIs.auth = FirebaseAuth.instance;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }

      log('logged out');
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1015),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1015),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFEF4444),
            onPressed: _handleLogoutBtnClick,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.06,
                vertical: mq.height * 0.03,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(_image!)),
                              radius: mq.height * 0.08,
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.08),
                              child: CachedNetworkImage(
                                width: mq.height * 0.16,
                                height: mq.height * 0.16,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  radius: mq.height * 0.08,
                                  backgroundColor: const Color(0xFF9333EA),
                                  child: Text(
                                    widget.user.name.isNotEmpty
                                        ? widget.user.name[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                        fontSize: mq.height * 0.05,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 2,
                          shape: const CircleBorder(),
                          onPressed: _showBottomSheet,
                          color: const Color(0xFF9333EA),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * 0.02),

                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        color: Color(0xFF8E92A2), fontSize: 16),
                  ),

                  SizedBox(height: mq.height * 0.04),

                  TextFormField(
                    initialValue: widget.user.name,
                    style: const TextStyle(color: Colors.white),
                    onSaved: (newValue) => APIs.me.name = newValue ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E2029),
                      prefixIcon: const Icon(CupertinoIcons.person,
                          color: Color(0xFF9333EA)),
                      hintText: 'Enter your name',
                      hintStyle: const TextStyle(color: Color(0xFF8E92A2)),
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Color(0xFF8E92A2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: mq.height * 0.02),

                  TextFormField(
                    initialValue: widget.user.about,
                    style: const TextStyle(color: Colors.white),
                    onSaved: (newValue) => APIs.me.about = newValue ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E2029),
                      prefixIcon: const Icon(CupertinoIcons.info,
                          color: Color(0xFF9333EA)),
                      hintText: 'Enter about details',
                      hintStyle: const TextStyle(color: Color(0xFF8E92A2)),
                      labelText: 'About',
                      labelStyle: const TextStyle(color: Color(0xFF8E92A2)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: mq.height * 0.04),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9333EA),
                      minimumSize: Size(mq.width * 0.5, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile updated successfully!');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    label: const Text(
                      'UPDATE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * 0.03,
            bottom: mq.height * 0.05,
          ),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: mq.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2029),
                    fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateUserProfilePicture(File(_image!));
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/add_image.png',
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image,
                              color: Color(0xFF9333EA), size: 40)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2029),
                    fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateUserProfilePicture(File(_image!));
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera.png',
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.camera_alt,
                              color: Color(0xFF9333EA), size: 40)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
