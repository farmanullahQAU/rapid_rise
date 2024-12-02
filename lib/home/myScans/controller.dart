import 'package:get/get.dart';
import 'package:rapid_rise/data/serivices/db_services.dart';
import 'package:rapid_rise/models/components_scan.dart';

class ScannedDataController extends GetxController {
  var scannedData = <ComponentScan>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchScannedData();
  }

  void fetchScannedData() async {
    try {
      isLoading(true);
      // Replace with your DatabaseService method
      final data = await DatabaseService().fetchMergedScannedData(2);
      scannedData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch scanned data.');
    } finally {
      isLoading(false);
    }
  }
}
