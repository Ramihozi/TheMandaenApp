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
      appBar: AppBar(
        backgroundColor: Colors.white, // White background for the AppBar
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Black back arrow
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Add Post',
          style: TextStyle(
            color: Colors.black, // Black text color for the title
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
        iconTheme: const IconThemeData(
          color: Colors.black, // Black color for other icons
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            child: Column(
              children: [
                Obx(() {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _profileController.url.value.isNotEmpty
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
                        : Container(),
                  );
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
                  minLines: 1,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Write here...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Obx(() {
                      if (_postController.selectedImagePath.value.isEmpty) {
                        return const Center(
                          child: Icon(
                            Icons.image,
                            size: 45,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_postController.selectedImagePath.value),
                            fit: BoxFit.contain, // Use BoxFit.contain to preserve aspect ratio
                            width: double.infinity,
                            height: double.infinity,
                          ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _postController.isLoading.value
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
