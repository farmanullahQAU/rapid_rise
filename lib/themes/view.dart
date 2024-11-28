import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class ThemeSettingsPage extends StatelessWidget {
  final SettingsController themeController = Get.put(SettingsController());

  ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select Your Preferred Theme',
              ),
              const SizedBox(height: 40),
              _buildThemeOption(
                context: context,
                icon: Icons.light_mode,
                title: 'Light Theme',
                mode: ThemeMode.light,
                description: 'Bright and clear mode.',
                themeController: themeController,
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context: context,
                icon: Icons.dark_mode,
                title: 'Dark Theme',
                mode: ThemeMode.dark,
                description: 'Reduce eye strain in dark environments.',
                themeController: themeController,
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context: context,
                icon: Icons.brightness_auto,
                title: 'System Default',
                mode: ThemeMode.system,
                description: 'Follows your system theme settings.',
                themeController: themeController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required ThemeMode mode,
    required String description,
    required SettingsController themeController,
    required BuildContext context,
  }) {
    return Obx(() {
      return GestureDetector(
        onTap: () {
          themeController.setTheme(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeController.themeMode.value == mode
                ? context.theme.colorScheme.surfaceContainer
                : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeController.themeMode.value == mode
                  ? context.theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 20),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: context.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(description, style: context.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              if (themeController.themeMode.value == mode)
                Icon(Icons.check_circle,
                    color: context.theme.colorScheme.primary),
            ],
          ),
        ),
      );
    });
  }
}
