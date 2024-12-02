import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rapid_rise/themes/view.dart';

import 'controller.dart';
import 'myScans/view.dart';

class HomePage extends StatelessWidget {
  final homeController = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                homeController.logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {
                  Get.to(() => ScannedDataPage());
                },
                value: 'myScans',
                child: const Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'My Scans',
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {
                  Get.to(() => ThemeSettingsPage());
                },
                value: 'themeSettings',
                child: const Row(
                  children: [
                    Icon(
                      Icons.dark_mode_outlined,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Theme Settings',
                      style: TextStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // User Profile Section
              Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, ${homeController.employee.firstName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // QR Scanner Section
              const Icon(
                Icons.qr_code_scanner,
                size: 60,
              ),
              const SizedBox(height: 30),
              // Scan Button
              Obx(() {
                if (homeController.isLoading.value) {
                  return const CircularProgressIndicator();
                } else {
                  return ElevatedButton.icon(
                    onPressed: () => homeController.scanBarcode(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Barcode'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 30),
              // Scan Result Section
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: homeController.scanResult.value.isEmpty
                      ? Text(
                          'No barcode scanned yet.',
                          style: Theme.of(context).textTheme.bodySmall,
                          key: const ValueKey('no_scan'),
                        )
                      : Container(
                          key: const ValueKey('scan_result'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Scanned Barcode',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                homeController.scanResult.value,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                homeController.scanMessage.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: context.theme.colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const Spacer(),
              // Footer Text
              Text(
                'Powered by RapidRise',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
