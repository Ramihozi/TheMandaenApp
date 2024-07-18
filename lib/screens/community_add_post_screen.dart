import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_mandean_app/screens/community_add_post_controller.dart';
import 'package:the_mandean_app/screens/community_profile_controller.dart';

class AddPostScreen extends StatelessWidget {
  AddPostScreen({super.key});

  final _profileController = Get.put(ProfileController());
  final _postController = Get.put(AddPostController());

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
                  return _profileController.url.value.isNotEmpty
                      ? Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          _profileController.url.value,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        _profileController.name.value,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  )
                      : Container();
                }),
                const SizedBox(
                  height: 14,
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
                const SizedBox(
                  height: 14,
                ),
                TextField(
                  controller: _postController.postTxtController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Write here...",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                GestureDetector(
                  onTap: () {
                    _postController.getImage();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Colors.white,
                    ),
                    child: Obx(() {
                      if (_postController.selectedImagePath.value.isEmpty) {
                        return Center(
                          child: Icon(
                            Icons.image,
                            size: 45,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        return Image.file(
                          File(_postController.selectedImagePath.value),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                    }),
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        _postController.addPost(
                          userName: _profileController.name.value,
                          userUrl: _profileController.url.value,
                        );
                      },
                      child: _postController.isLoading.value
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
