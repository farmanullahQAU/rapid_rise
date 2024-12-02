import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../connection_view/view.dart';
import 'controller.dart';

class LoginPage extends StatelessWidget {
  final loginController = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            Get.to(() => DbConnectPage());
          },
          child: Text(
            'Login',
            style: theme.textTheme.titleLarge,
          ),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    theme.primaryColor.withOpacity(0.8),
                    theme.scaffoldBackgroundColor
                  ]
                : [theme.primaryColor, theme.scaffoldBackgroundColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: Get.width * 0.5,
                ),

                SizedBox(height: Get.height * 0.1),
                // Title
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Username field
                Obx(() => TextField(
                      controller: loginController.usernameController.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: 'Username',
                        labelStyle: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Password field
                Obx(() => TextField(
                      controller: loginController.passwordController.value,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Password',
                        labelStyle: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    )),
                const SizedBox(height: 32),

                // Login button
                Obx(() => FilledButton(
                      onPressed: loginController.isLoading.value
                          ? null
                          : loginController.login,
                      style: FilledButton.styleFrom(
                        fixedSize: Size.fromWidth(Get.width),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: loginController.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
