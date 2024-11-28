import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/serivices/db_services.dart';
import '../home/view.dart';
import '../models/employee.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final isLoading = false.obs;

  Employee? employee;
  final DatabaseService apiRepository = DatabaseService();
  void login() async {
    try {
      final username = usernameController.value.text;
      final password = passwordController.value.text;

      // Basic input validation
      if (username.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Username and password cannot be empty.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      employee = await apiRepository.login(
        username,
        password,
      );

      if (employee != null) {
        Get.off(() => HomePage(), arguments: employee);
      }
    } catch (err) {
      Get.snackbar(
        'Error',
        err.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
