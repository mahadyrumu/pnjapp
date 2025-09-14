import 'package:get/get.dart';
import 'package:parknjet_app/models/prepaid_packages/prepaid_package.dart';
import 'package:parknjet_app/services/prepaid_package_service.dart';

class PrepaidPackageController extends GetxController {
  var isLoading = true.obs;
  var packages = <PrepaidPackage>[].obs;
  var lot1PrepaidDays = 0.0.obs;
  var lot2PrepaidDays = 0.0.obs;
  var lot1ExpirationDate = ''.obs;
  var lot2ExpirationDate = ''.obs;

  final PrepaidPackageService _prepaidPackageService = PrepaidPackageService();

  @override
  void onInit() {
    super.onInit();
    fetchPrepaidPackages();
    fetchPrepaidPackageDays();
  }

  Future<void> fetchPrepaidPackages() async {
    try {
      isLoading.value = true;
      var fetchedPackages = await _prepaidPackageService.fetchPrepaidPackages();
      packages.assignAll(fetchedPackages);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load prepaid packages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrepaidPackageDays() async {
    try {
      isLoading(true);
      var data = await PrepaidPackageService.fetchPrepaidPackageDays();

      lot1PrepaidDays.value = data['lot1PrepaidDays']['days'].toDouble();
      lot2PrepaidDays.value = data['lot2PrepaidDays']['days'].toDouble();
      lot1ExpirationDate.value = data['lot1PrepaidDays']['expirationDate'];
      lot2ExpirationDate.value = data['lot2PrepaidDays']['expirationDate'];

      // print("Lot 1 Days: ${lot1PrepaidDays.value}");
      // print("Lot 2 Days: ${lot2PrepaidDays.value}");
    } catch (e) {
      print("Error fetching prepaid package days: $e");
    } finally {
      isLoading(false);
    }
  }
}
