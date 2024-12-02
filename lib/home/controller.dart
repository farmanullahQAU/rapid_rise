// import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:vertex_stairs/data/serivices/db_services.dart';
// import 'package:vertex_stairs/login/view.dart';
// import 'package:vertex_stairs/models/employee.dart';

// class HomeController extends GetxController {
//   final databaseService = DatabaseService();

//   // Observables for UI updates
//   final scanResult = ''.obs;
//   final scanMessage = ''.obs;
//   final isLoading = false.obs;

//   late Employee employee;

//   @override
//   void onInit() {
//     // Initialize employee from passed arguments
//     employee = Get.arguments;
//     super.onInit();
//   }

//   Future<void> scanBarcode() async {
//     try {
//       // Start barcode scanning
//       String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666', // Scanner color
//         'Cancel', // Cancel button text
//         true, // Show flash icon
//         ScanMode.BARCODE,
//       );

//       if (barcodeScanResult == '-1') {
//         scanMessage.value = "Scanning cancelled.";
//         return;
//       }

//       scanResult.value = barcodeScanResult;
//       _handleScannedData(barcodeScanResult);
//     } catch (e) {
//       scanMessage.value = "An error occurred while scanning: $e";
//     }
//   }

//   void _handleScannedData(String barcodeData) {
//     final parts = barcodeData.split('-');

//     if (parts.length != 2) {
//       scanMessage.value =
//           "Invalid barcode format. Expected format: <ComponentID>-<FlightID>";
//       return;
//     }

//     final componentId = parts[0];
//     final flightId = parts[1];

//     _checkComponentStatus(int.parse(componentId), int.parse(flightId));
//   }

//   Future<void> _checkComponentStatus(int componentId, int flightId) async {
//     try {
//       isLoading.value = true;

//       final message = await databaseService.checkAndInsertComponentScan(
//           componentId: '$componentId',
//           flightId: '$flightId',
//           userId: "${employee.employeeID}");

//       _showToast(message!, isError: false);
//     } catch (e) {
//       isLoading.value = false;
//       _showToast(e.toString(), isError: true);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _showToast(String message, {bool isError = false}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.CENTER,
//       backgroundColor: isError ? Colors.red : Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

//   Future<void> logout() async {
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         title: const Text('Confirm Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             style: TextButton.styleFrom(),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       Get.off(() => LoginPage());
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rapid_rise/data/serivices/db_services.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../login/view.dart';
import '../models/employee.dart';

class HomeController extends GetxController {
  final databaseService = DatabaseService();

  // Observables for UI updates
  final scanResult = ''.obs;
  final scanMessage = ''.obs;
  final isLoading = false.obs;

  late Employee employee;

  @override
  void onInit() {
    // Initialize employee from passed arguments
    employee = Get.arguments;
    super.onInit();
  }

  Future<void> scanBarcode(BuildContext context) async {
    try {
      scanMessage.value = '';
      // Start barcode scanning
      final barcodeScanResult = await SimpleBarcodeScanner.scanBarcode(context);

      if (barcodeScanResult == null || barcodeScanResult.isEmpty) {
        scanMessage.value = "Scanning cancelled.";
        return;
      }

      scanResult.value = barcodeScanResult;
      _handleScannedData(barcodeScanResult);
    } catch (e) {
      scanMessage.value = "An error occurred while scanning: $e";
    }
  }

  void _handleScannedData(String barcodeData) {
    final parts = barcodeData.split('-');

    if (parts.length != 2) {
      scanMessage.value =
          "Invalid barcode format. Expected format: <ComponentID>-<FlightID>";
      return;
    }

    final componentId = parts[0];
    final flightId = parts[1];

    _checkComponentStatus(int.parse(componentId), int.parse(flightId));
  }

  Future<void> _checkComponentStatus(int componentId, int flightId) async {
    try {
      isLoading.value = true;

      final message = await databaseService.checkAndInsertComponentScan(
          componentId: '$componentId',
          flightId: '$flightId',
          userId: "${employee.employeeID}");

      _showToast(message!, isError: false);
    } catch (e) {
      isLoading.value = false;
      _showToast(e.toString(), isError: true);
      scanMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.off(() => LoginPage());
    }
  }
}
