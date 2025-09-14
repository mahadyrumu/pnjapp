import 'package:get/get.dart';
import 'package:parknjet_app/models/availability/mem_quotes.dart';
import 'package:parknjet_app/services/mem_quotes.dart';

class QuotesController extends GetxController {
  RxString quoteErrorMessage = "".obs;

  void setQuoteErrorMessage(String value) {
    quoteErrorMessage.value = value; // Set the string value
  }

  void resetQuoteErrorMessage() {
    quoteErrorMessage.value = ""; // Reset the string value
  }

  Future<GetMemQuote> fetchQuote(Map<String, dynamic> payload) async {
    try {
      return await QuoteService().fetchQuotes(payload);
    } catch (e) {
      quoteErrorMessage.value = 'Error fetching quotes: $e';
      rethrow;
    }
  }
}
