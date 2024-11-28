import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rapid_rise/login/view.dart';

import '../data/serivices/db_services.dart';

class DbController extends GetxController {
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController(text: 'sa');
  final passwordController = TextEditingController(text: 'Pakistan12');
  final databaseNameController = TextEditingController(text: 'VertexStairsDB');

  final isLoading = false.obs;

  Future<void> connectToDb() async {
    // Perform validations here if necessary
    isLoading.value = true;

    try {
      final connected = await DatabaseService().connect(
        ip: ipController.text.trim(),
        port: portController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        databaseName: databaseNameController.text.trim(),
      );
      isLoading.value = false;

      if (connected) {
        _showToast("Connection Established", isError: false);
        Get.off(() => LoginPage());
      } else {
        _showToast("Connection Failed", isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      _showToast("Error: ${e.toString()}", isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void onClose() {
    ipController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    databaseNameController.dispose();
    super.onClose();
  }
}
