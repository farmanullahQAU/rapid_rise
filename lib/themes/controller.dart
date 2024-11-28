import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  var themeMode = ThemeMode.system.obs; // Default to system theme

  // Toggle theme mode
  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode); // Apply theme change globally
  }
}
