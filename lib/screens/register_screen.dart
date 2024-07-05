import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_mandean_app/constants/constants.dart';
import 'package:the_mandean_app/screens/text_field_decoration_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_mandean_app/screens/register_controller.dart';


class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _registrationController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: height * 0.3,
                    decoration: const BoxDecoration(
                      color: lightPrimaryColor, // that pink color is because of this
                      // here I have fixed for lightTheme, We will change it later
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 30,
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 38, left: 8, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // I have added this --> Profile picture
                    // rest of the code is same
                    GestureDetector(
                      onTap: () async {
                        _registrationController.getImage(ImageSource.gallery);
                      },
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Obx(
                                () => _registrationController.selectedImagePath.value == ''
                                ? const CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                ))
                                : CircleAvatar(
                              radius: 80,
                              backgroundImage: Image.file(
                                File(_registrationController.selectedImagePath.value),
                                fit: BoxFit.fill,
                              ).image,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8,),
                    Form(
                      key: _registrationController.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              // The validator receives the text that the user has entered.
                              controller:
                              _registrationController.nameController,
                              onSaved: (value) {
                                _registrationController.name = value!;
                              },
                              validator: (value) {
                                return _registrationController
                                    .validName(value!);
                              },
                              decoration: decorationWidget(
                                  context,
                                  "User Name",
                                  Icons.person),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              // The validator receives the text that the user has entered.
                              controller:
                              _registrationController.emailController,
                              onSaved: (value) {
                                _registrationController.email = value!;
                              },
                              validator: (value) {
                                return _registrationController
                                    .validEmail(value!);
                              },
                              decoration: decorationWidget(
                                  context, "Email", Icons.email),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                obscureText: true,
                                controller:
                                _registrationController.passwordController,
                                onSaved: (value) {
                                  _registrationController.password = value!;
                                },
                                validator: (value) {
                                  return _registrationController
                                      .validPassword(value!);
                                },
                                decoration: decorationWidget(
                                    context, "Password", Icons.vpn_key)),
                          ),
                          const SizedBox(height: 24,),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  textStyle:
                                  Theme.of(context).textTheme.headlineMedium),
                              child: _registrationController.isLoading.value
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : FittedBox(
                                child: Obx(
                                      () => _registrationController
                                      .isLoading.value
                                      ? const Center(
                                    child:
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Text(
                                    'Register',
                                  ),
                                ),
                              ),
                              onPressed: () {
                                _registrationController.userRegister();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text('Already have an account ? ',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16),),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed('/login_screen');
                    },
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}