import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'profile_tab/community_profile_controller.dart';

class CreateStory extends StatelessWidget {
  const CreateStory({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference users = FirebaseFirestore.instance.collection('user');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user!.uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          String profileImageUrl = data['url'] ?? 'https://example.com/default-profile-image.jpg';

          // Use Obx to reactively listen to changes in language settings
          return Obx(() {
            final bool isEnglish = Get.find<ProfileController>().isEnglish.value;

            // Define your translations and font sizes here
            final String storyText = isEnglish ? 'My Story' : 'قصتي';
            final double fontSize = isEnglish ? 16.0 : 16.0; // Adjust sizes as needed

            return GestureDetector(
              onTap: onTap, // Triggered on tap
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              // Use NetworkImage to load image from URL
                              image: NetworkImage(profileImageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: -1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      storyText,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.8),
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize, // Apply the font size based on language
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        }

        return const CircularProgressIndicator(); // While loading
      },
    );
  }
}
