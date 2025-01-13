import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ImageCropScreen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key, required userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());
  final ImageCropScreen _imageCropScreen = ImageCropScreen();

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference(); // Load language preference on startup
  }

  // Method to load the saved language preference
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedIsEnglish = prefs.getBool('isEnglish');
    if (savedIsEnglish != null) {
      _controller.isEnglish.value = savedIsEnglish;
      print('Language loaded: ${_controller.isEnglish.value
          ? 'English'
          : 'Arabic'}');
    }
  }

  // Method to toggle the language state and save it
  Future<void> _toggleLanguage() async {
    _controller.isEnglish.value = !_controller.isEnglish.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'isEnglish', _controller.isEnglish.value); // Save language preference
    print('Language toggled: ${_controller.isEnglish.value
        ? 'English'
        : 'Arabic'}');
  }

  // Method to get text based on language preference
  String _getText(String englishText, String arabicText) {
    return _controller.isEnglish.value ? englishText : arabicText;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle englishTextStyle = TextStyle(
        fontSize: 15.0); // Default font size for English
    final TextStyle arabicTextStyle = TextStyle(
        fontSize: 19.0); // Larger font size for Arabic

    TextStyle _getTextStyle() {
      return _controller.isEnglish.value ? englishTextStyle : arabicTextStyle;
    }

    return Scaffold(
      body: Obx(() {
        return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      return _controller.url.value.isNotEmpty
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  imageUrl: _controller.url.value,
                                  placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/account.png'),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    XFile? pickedFile =
                                    await _imageCropScreen.pickImage();

                                    if (pickedFile != null) {
                                      CroppedFile? croppedFile =
                                      await _imageCropScreen
                                          .crop(file: pickedFile);

                                      if (croppedFile != null) {
                                        await _controller.updateProfilePicture(
                                            croppedFile.path);
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _controller.name.value,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _controller.email.value,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                          : Container();
                    }),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.black26),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text(_getText(
                                    'Confirm Deletion', 'تأكيد الحذف')),
                                content: Text(
                                  _getText(
                                      'Are you sure you want to delete your account? This action cannot be undone.',
                                      'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(_getText('Cancel', 'إلغاء')),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(_getText('Delete', 'حذف')),
                                  ),
                                ],
                              ),
                        );

                        if (confirmDelete == true) {
                          String? password = await _showPasswordDialog(context);

                          if (password != null && password.isNotEmpty) {
                            await _controller.deleteUserAccount(
                                context, password);
                          } else {
                            print('Password not provided.');
                          }
                        }
                      },
                      child: Text(
                        _getText('Delete Account', 'حذف الحساب'),
                        style: _getTextStyle(), // Apply custom text style here
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirmChangePassword = await showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text(_getText(
                                    'Change Password', 'تغيير كلمة المرور')),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _controller
                                          .currentPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          labelText: _getText(
                                              'Current Password',
                                              'كلمة المرور الحالية')),
                                    ),
                                    TextField(
                                      controller: _controller
                                          .newPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          labelText: _getText('New Password',
                                              'كلمة المرور الجديدة')),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(_getText('Cancel', 'إلغاء')),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(_getText('Change', 'تغيير')),
                                  ),
                                ],
                              ),
                        );

                        if (confirmChangePassword == true) {
                          String currentPassword =
                              _controller.currentPasswordController.text;
                          String newPassword = _controller.newPasswordController
                              .text;

                          if (currentPassword.isNotEmpty &&
                              newPassword.isNotEmpty) {
                            await _controller.changePassword(
                                context, currentPassword, newPassword);
                          } else {
                            print('Password fields cannot be empty.');
                          }
                        }
                      },
                      child: Text(
                        _getText('Change Password', 'تغيير كلمة المرور'),
                        style: _getTextStyle(), // Apply custom text style here
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        launchURL(
                            'https://ramihozi.github.io/GinzAppPage/support.html');
                      },
                      child: Text(_getText('Support', 'الدعم'),
                        style: _getTextStyle(), // Apply custom text style here
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _controller.blockedUsers.isNotEmpty
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getText('Blocked Users:', 'المستخدمين المحظورين:'),
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium, // Existing style
                          ),
                          const SizedBox(height: 10),
                          ..._controller.blockedUsers.map((user) {
                            return ListTile(
                              title: Text(
                                user['name'] ?? _getText('Unknown', 'مجهول'),
                                style: _getTextStyle(), // Apply the appropriate text style here
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                    Icons.remove_circle, color: Colors.red),
                                onPressed: () async {
                                  bool? confirmUnblock = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          title: Text(_getText(
                                              'Confirm Unblock',
                                              'تأكيد إلغاء الحظر')),
                                          content: Text(
                                            _getText(
                                              'Are you sure you want to unblock this user?',
                                              'هل أنت متأكد أنك تريد إلغاء حظر هذا المستخدم؟',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      false),
                                              child: Text(
                                                  _getText('Cancel', 'إلغاء')),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      true),
                                              child: Text(_getText(
                                                  'Unblock', 'إلغاء الحظر')),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirmUnblock == true) {
                                    await _controller.unblockUser(user['id']!);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      )
                          : Text(
                        _getText(
                            'No blocked users.', 'لا يوجد مستخدمين محظورين.'),
                        style: _getTextStyle(), // Apply the custom text style here
                      );
                    }),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.black26),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(
                            () =>
                            ElevatedButton(
                              onPressed: _toggleLanguage,
                              // Use the method to toggle state
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.grey[200],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    _controller.isEnglish.value
                                        ? 'assets/images/english.png'
                                        : 'assets/images/arabic.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _controller.isEnglish.value ? 'EN' : 'AR',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        );
      }),
    );
  }

// Method to show a password dialog for account deletion confirmation
  Future<String?> _showPasswordDialog(BuildContext context) async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(_getText('Enter Password', 'أدخل كلمة المرور')),
            content: TextField(
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                  labelText: _getText('Password', 'كلمة المرور')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_getText('Cancel', 'إلغاء')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_getText('Submit', 'تأكيد')),
              ),
            ],
          ),
    );
    return password;
  }
}

void launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}