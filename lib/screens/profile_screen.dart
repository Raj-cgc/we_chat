import "dart:developer";
import "dart:io";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
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
    //show progress dialog
    Dialogs.showProgressBar(context);

    //update active status to false before logging off
    APIs.updateActiveStatus(false);

    //sign out of the app
    await AutProvider.signOut().then((value) async {
      //for removing progressbar from navigation stack
      Navigator.pop(context);

      //for removing home screen from navigation stack...or else
      //we will come back to home screen if clicked back from loginScreen
      Navigator.pop(context);

      APIs.auth = FirebaseAuth.instance;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      log('logged out');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard on pressing anywhere on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Profile Screen')),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: _handleLogoutBtnClick,
            icon: Icon(Icons.logout),
            label: Text('Logout'),
          ),
        ),

        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.05,
                vertical: mq.height * 0.05,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                            //if image not null then it means chosen from gallery
                            //use that photo in circleAvatar
                            backgroundImage: FileImage(File(_image!)),
                            radius: mq.height * 0.11,
                          )
                          : CircleAvatar(
                            //else use the default photo from networkImage
                            backgroundImage: NetworkImage(widget.user.image),
                            radius: mq.height * 0.11,
                          ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          shape: CircleBorder(),
                          onPressed: _showBottomSheet,
                          color: Colors.blue,
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * 0.03),

                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),

                  SizedBox(height: mq.height * 0.03),

                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (newValue) => APIs.me.name = newValue ?? '',
                    validator:
                        (value) =>
                            value != null && value.isNotEmpty
                                ? null
                                : 'Required Field',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      hintText: 'Enter your name',
                      label: Text('Name'),
                    ),
                  ),

                  SizedBox(height: mq.height * 0.02),

                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (newValue) => APIs.me.about = newValue ?? '',
                    validator:
                        (value) =>
                            value != null && value.isNotEmpty
                                ? null
                                : 'Required Field',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                      hintText: 'Enter your status',
                      label: Text('About'),
                    ),
                  ),

                  SizedBox(height: mq.height * 0.03),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(mq.width * 0.4, mq.height * 0.06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                            context,
                            'Profile Updated Successfully',
                          );
                        });

                        log('inside validator');
                      }
                    },
                    icon: Icon(Icons.edit, size: 28),
                    label: Text('Update', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //show bottom sheet for picking a profile pic for user
  void _showBottomSheet() {
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
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          children: [
            Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 15),

            Row(
              //for picking image from gallery
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final ImagePicker picker = ImagePicker();

                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log(image.path);
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateUserProfilePicture(File(_image!));
                    }
                  },
                  child: Image.asset('images/add_image.png'),
                ),

                //for picking image from camera
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
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
                    }
                    Navigator.of(context).pop();
                  },
                  child: Image.asset('images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


}
