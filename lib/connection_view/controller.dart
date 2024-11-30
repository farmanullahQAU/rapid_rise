import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rapid_rise/login/view.dart';

import '../data/serivices/db_services.dart';

class DbController extends GetxController {
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final databaseNameController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved connection parameters on initialization
    _loadSavedParams();
  }

  Future<void> _loadSavedParams() async {
    final savedParams = await DatabaseService().getConnectionParams();

    ipController.text = savedParams['ip'] ?? '';
    portController.text = savedParams['port'] ?? '';
    usernameController.text = savedParams['username'] ?? '';
    databaseNameController.text = savedParams['databaseName'] ?? '';
    passwordController.text = savedParams['password'] ?? '';
  }

  // Toast notification method
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> connectToDb() async {
    // Validate input fields
    if (ipController.text.trim().isEmpty ||
        portController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        databaseNameController.text.trim().isEmpty) {
      _showToast("Please fill in all connection details", isError: true);
      return;
    }

    // Set loading state
    isLoading.value = true;

    try {
      final connected = await DatabaseService().connect(
        ip: ipController.text.trim(),
        port: portController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        databaseName: databaseNameController.text.trim(),
      );

      // Reset loading state
      isLoading.value = false;

      if (connected) {
        _showToast("Connection Established", isError: false);
        Get.off(() => LoginPage());
      } else {
        _showToast("Connection Failed", isError: true);
      }
    } catch (e) {
      // Reset loading state
      isLoading.value = false;
      _showToast("Error: ${e.toString()}", isError: true);
    }
  }
}
