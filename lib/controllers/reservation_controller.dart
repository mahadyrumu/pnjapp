import 'package:get/get.dart';
import 'package:parknjet_app/models/reservations/reservations.dart';
import 'package:parknjet_app/services/reservation_service.dart';

class ReservationController extends GetxController {
  var reservations = <ReservationDataModel>[].obs;
  var isLoading = true.obs;

  Future<void> fetchReservations() async {
    try {
      isLoading.value = true;
      List<ReservationDataModel> fetchReservations =
          await ReservationService.fetchReservations();
      fetchReservations.sort((a, b) => b.rsvnId.compareTo(a.rsvnId));
      reservations.assignAll(fetchReservations);
    } catch (e) {
      print('Error fetching reservations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReservations() async {
    await fetchReservations();
  }
}
