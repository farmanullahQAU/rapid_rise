import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class DbConnectPage extends StatelessWidget {
  final DbController dbController = Get.put(DbController());
  final _formKey = GlobalKey<FormState>();

  DbConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect to MS-SQL',
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/logo.png',
                        width: Get.width * 0.1,
                        height: Get.width * 0.1,
                      ),
                      _buildCustomTextField(
                        controller: dbController.ipController,
                        label: "IP Address",
                        validator: (value) =>
                            value!.isEmpty ? "Please enter IP Address" : null,
                        keyboardType: TextInputType.number,
                        theme: theme,
                      ),
                      _buildCustomTextField(
                        controller: dbController.portController,
                        label: "Port",
                        validator: (value) =>
                            value!.isEmpty ? "Please enter Port" : null,
                        keyboardType: TextInputType.number,
                        theme: theme,
                      ),
                      _buildCustomTextField(
                        controller: dbController.databaseNameController,
                        label: "Database Name",
                        validator: (value) => value!.isEmpty
                            ? "Please enter Database Name"
                            : null,
                        theme: theme,
                      ),
                      _buildCustomTextField(
                        controller: dbController.usernameController,
                        label: "Username",
                        validator: (value) =>
                            value!.isEmpty ? "Please enter Username" : null,
                        theme: theme,
                      ),
                      _buildCustomTextField(
                        controller: dbController.passwordController,
                        label: "Password",
                        validator: (value) =>
                            value!.isEmpty ? "Please enter Password" : null,
                        obscureText: true,
                        theme: theme,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: dbController.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  dbController.connectToDb();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          dbController.isLoading.value
                              ? "Connecting..."
                              : "Connect",
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Ensure that your database credentials are correct.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dbController.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
