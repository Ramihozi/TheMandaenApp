import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            child: Column(
              children: [
                Obx(() {
                  return _controller.url.value.isNotEmpty
                      ? Row(
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _controller.name.value,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.email.value,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  )
                      : Container();
                }),
                const SizedBox(height: 14),
                const Divider(thickness: 1, color: Colors.black26),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Deletion'),
                        content: Text(
                            'Are you sure you want to delete your account? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      // Ask user for their password before deleting the account
                      String? password = await _showPasswordDialog(context);

                      if (password != null && password.isNotEmpty) {
                        // Pass the password to the deleteUserAccount method
                        await _controller.deleteUserAccount(context, password);
                      } else {
                        // Optionally handle the case where the password is not provided
                        print('Password not provided.');
                      }
                    }
                  },
                  child: Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Prompt user for current and new passwords
                    bool? confirmChangePassword = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Change Password'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _controller.currentPasswordController,
                              obscureText: true,
                              decoration:
                              InputDecoration(labelText: 'Current Password'),
                            ),
                            TextField(
                              controller: _controller.newPasswordController,
                              obscureText: true,
                              decoration:
                              InputDecoration(labelText: 'New Password'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Change'),
                          ),
                        ],
                      ),
                    );

                    if (confirmChangePassword == true) {
                      String currentPassword =
                          _controller.currentPasswordController.text;
                      String newPassword =
                          _controller.newPasswordController.text;

                      if (currentPassword.isNotEmpty &&
                          newPassword.isNotEmpty) {
                        await _controller.changePassword(
                            context, currentPassword, newPassword);
                      } else {
                        // Optionally handle empty password fields
                        print('Password fields cannot be empty.');
                      }
                    }
                  },
                  child: Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return _controller.blockedUsers.isNotEmpty
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blocked Users:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      ..._controller.blockedUsers.map((user) {
                        return ListTile(
                          title: Text(user['name'] ?? 'Unknown'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () async {
                              // Confirm unblock
                              bool? confirmUnblock = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Unblock'),
                                  content: Text(
                                      'Are you sure you want to unblock this user?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Unblock'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmUnblock == true) {
                                await _controller
                                    .unblockUser(user['id']!);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  )
                      : Text('No blocked users.');
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    launchURL('https://ramihozi.github.io/GinzAppPage/support.html');
                  },
                  child: Text('Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    String? password;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Re-authenticate'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                password = passwordController.text;
                Navigator.of(context).pop(password);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}