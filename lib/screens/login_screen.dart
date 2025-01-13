import 'package:flutter/material.dart';
import 'package:the_mandean_app/constants/constants.dart';
import 'package:the_mandean_app/screens/login_controller.dart';
import 'package:get/get.dart';

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

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.05),
                Center(
                  child: Image.asset(
                    'assets/images/darfesh1.jpeg', // replace with your logo asset path
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome To GinzApp!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _loginController.formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: _loginController.emailController,
                          onSaved: (value) {
                            _loginController.email = value!;
                          },
                          validator: (value) {
                            return _loginController.validEmail(value!);
                          },
                          decoration: decorationWidget(
                            context,
                            "Email Address",
                            Icons.email,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          obscureText: true,
                          controller: _loginController.passwordController,
                          onSaved: (value) {
                            _loginController.password = value!;
                          },
                          validator: (value) {
                            return _loginController.validPassword(value!);
                          },
                          decoration: decorationWidget(
                            context,
                            "Password",
                            Icons.lock,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(() => Text(
                        _loginController.errorMessage.value,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      )), // Display error message
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.amber, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: Theme.of(context).textTheme.headlineMedium,
                            ),
                            child: FittedBox(
                              child: Obx(
                                    () => _loginController.isLoading.value
                                    ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                  ),
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              _loginController.login();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.offNamed('/register_screen');
                      },
                      child: Text(
                        'Register',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}