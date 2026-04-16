import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class ReadingService {
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  Future<String> generateCoffeeReading({
    required String topic,
    required String userNote,
  }) async {
    return _callFunction(falType: 'coffee', topic: topic, userNote: userNote);
  }

  Future<String> generateTarotReading({
    required String topic,
    required String userNote,
    required List<String> cardNames,
  }) async {
    return _callFunction(
        falType: 'tarot', topic: topic, userNote: userNote, cardNames: cardNames);
  }

  Future<String> generatePalmReading({
    required String uid,
    required String topic,
    required String userNote,
  }) async {
    return _callFunction(falType: 'palm', topic: topic, userNote: userNote);
  }

  Future<String> _callFunction({
    required String falType,
    required String topic,
    required String userNote,
    List<String>? cardNames,
  }) async {
    debugPrint('[READ] start — falType=$falType  topic=$topic');
    debugPrint('[READ] request sent — function=generateFalReading  region=europe-west1');

    final callable = _functions.httpsCallable(
      'generateFalReading',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 120),
      ),
    );

    try {
      final result = await callable.call<Map<String, dynamic>>({
        'falType': falType,
        'topic': topic,
        'userNote': userNote,
        if (cardNames != null) 'cardNames': cardNames,
      });

      debugPrint('[READ] function response received');
      debugPrint('[READ] response keys = ${result.data.keys.toList()}');

      final reading = result.data['reading'] as String?;

      if (reading == null || reading.trim().isEmpty) {
        debugPrint('[READ] error — response is null or empty');
        throw Exception('Sunucudan boş yanıt geldi. Lütfen tekrar deneyin.');
      }

      debugPrint('[READ] result loaded — length=${reading.length} chars');
      return reading;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[READ] error — FirebaseFunctionsException code=${e.code}  message=${e.message}  details=${e.details}');
      if (e.code == 'deadline-exceeded' || e.message?.contains('timeout') == true) {
        debugPrint('[READ] timeout — function exceeded 120s');
        throw Exception('Yorum hazırlanırken zaman aşımı oluştu. Lütfen tekrar deneyin.');
      }
      throw Exception('Sunucu hatası (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('[READ] error — $e');
      rethrow;
    }
  }
}
