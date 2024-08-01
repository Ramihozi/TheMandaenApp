import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_mandean_app/screens/register_controller.dart';
import '../constants/constants.dart';
import 'ImageCropScreen.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

InputDecoration decorationWidget(BuildContext context, String labelText, IconData icon) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(icon, color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: lightPrimaryColor,
        width: 2.0,
      ),
    ),
  );
}

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _registrationController = Get.put(RegisterController());
  final _imageCropScreen = ImageCropScreen(); // Create an instance of Imagecropscreen

  Future<void> _pickAndCropImage(BuildContext context) async {
    // Pick the image
    final pickedFile = await _imageCropScreen.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (pickedFile != null) {
      // Crop the image with a circular crop style
      final croppedFile = await _imageCropScreen.crop(
        file: pickedFile,
        cropStyle: CropStyle.circle,
      );
      if (croppedFile != null) {
        _registrationController.selectedImagePath.value = croppedFile.path;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.05),
                Center(
                  child: GestureDetector(
                    onTap: () => _pickAndCropImage(context),
                    child: Obx(
                          () => CircleAvatar(
                        radius: 60,
                        backgroundImage: _registrationController.selectedImagePath.value.isEmpty
                            ? null
                            : Image.file(File(_registrationController.selectedImagePath.value)).image,
                        child: _registrationController.selectedImagePath.value.isEmpty
                            ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome!\nCreate an account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _registrationController.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _registrationController.nameController,
                          onSaved: (value) {
                            _registrationController.name = value!;
                          },
                          validator: (value) {
                            return _registrationController.validName(value!);
                          },
                          decoration: decorationWidget(context, "User Name", Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: _registrationController.emailController,
                          onSaved: (value) {
                            _registrationController.email = value!;
                          },
                          validator: (value) {
                            return _registrationController.validEmail(value!);
                          },
                          decoration: decorationWidget(context, "Email", Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: true,
                          controller: _registrationController.passwordController,
                          onSaved: (value) {
                            _registrationController.password = value!;
                          },
                          validator: (value) {
                            return _registrationController.validPassword(value!);
                          },
                          decoration: decorationWidget(context, "Password", Icons.vpn_key),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                            () => CheckboxListTile(
                          title: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'By Registering You Agree To This App\'s ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: 'Terms & Policies',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch('https://ramihozi.github.io/GinzAppPage/privacy.html');
                                    },
                                ),
                              ],
                            ),
                          ),
                          value: _registrationController.isAgreed.value,
                          onChanged: (bool? value) {
                            _registrationController.toggleAgreement(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(
                              () => OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.amber, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: _registrationController.isAgreed.value ? Colors.transparent : Colors.grey[300],
                            ),
                            onPressed: _registrationController.isAgreed.value
                                ? () {
                              if (_registrationController.selectedImagePath.value.isEmpty) {
                                Get.snackbar(
                                  'Image Required',
                                  'Please upload a profile picture to continue.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                _registrationController.userRegister();
                              }
                            }
                                : null,
                            child: _registrationController.isLoading.value
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                            )
                                : const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          _registrationController.resetImagePath();
                          Get.offAllNamed('/login_screen');
                        },
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
