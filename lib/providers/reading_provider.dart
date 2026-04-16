import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/reading_model.dart';
import '../services/firestore_service.dart';
import '../services/reading_service.dart';

class ReadingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ReadingService _readingService = ReadingService();

  List<ReadingModel> _readings = [];
  bool _isLoading = false;
  String? _error;

  List<ReadingModel> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<ReadingModel?> startCoffeeReading({
    required String uid,
    required String topic,
    required String userNote,
    required List<File> images,
  }) async {
    _setLoading(true);
    _error = null;
    debugPrint('[READ] start — type=coffee  uid=$uid');

    try {
      debugPrint('[COFFEE] selected images count = ${images.length}');
      final analysisValid =
          images.length == 4 && images.every((f) => f.existsSync());
      debugPrint('[COFFEE] analysis valid = $analysisValid');

      if (!analysisValid) {
        _error = '4 fotoğraf gerekli. Lütfen tüm fotoğrafları yükleyin.';
        notifyListeners();
        return null;
      }

      // Kredi düş
      try {
        await _firestoreService.decrementCredit(uid);
        debugPrint('[READ] credit decremented for uid=$uid');
      } catch (e) {
        debugPrint('[READ] error — decrementCredit failed: $e');
        _error = 'Kredi düşülemedi. Lütfen tekrar deneyin.';
        notifyListeners();
        return null;
      }

      // Fotoğrafları yükle (opsiyonel, başarısız olsa da devam et)
      final readingId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> imageUrls = [];
      try {
        imageUrls =
            await _firestoreService.uploadImages(uid, images, readingId);
        debugPrint('[READ] images uploaded = ${imageUrls.length}');
      } catch (e) {
        debugPrint('[READ] image upload failed: $e — continuing without URLs');
      }

      // Cloud Function çağır
      debugPrint('[READ] request sent — coffee function call starting');
      String readingText;
      try {
        readingText = await _readingService.generateCoffeeReading(
          topic: topic,
          userNote: userNote,
        );
      } catch (e) {
        debugPrint('[READ] error — function call failed: $e');
        // Krediyi geri ver
        try {
          await _firestoreService.addCredits(uid, 1);
          debugPrint('[READ] credit refunded after function failure');
        } catch (refundErr) {
          debugPrint('[READ] refund failed: $refundErr');
        }
        _error = 'Yorum oluşturulamadı: $e';
        notifyListeners();
        return null;
      }

      debugPrint('[READ] function response received — coffee');
      debugPrint('[READ] result loaded — length=${readingText.length}');

      final reading = ReadingModel(
        id: readingId,
        userId: uid,
        type: ReadingType.coffee,
        topic: topic,
        userNote: userNote,
        reading: readingText,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      // Firestore'a kaydet
      debugPrint('[READ] firestore write start');
      try {
        await _firestoreService.saveReading(reading);
        debugPrint('[READ] firestore write success');
        await loadReadings(uid);
      } catch (e) {
        debugPrint('[READ] firestore write failed: $e — using local');
        _readings = [reading, ..._readings];
        notifyListeners();
      }

      return reading;
    } catch (e) {
      debugPrint('[READ] error — startCoffeeReading unexpected: $e');
      _error = 'Fal yorumu oluşturulamadı. Lütfen tekrar deneyin.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ReadingModel?> startTarotReading({
    required String uid,
    required String topic,
    required String userNote,
    required List<String> cardNames,
  }) async {
    _setLoading(true);
    _error = null;
    debugPrint('[READ] start — type=tarot  uid=$uid');

    try {
      try {
        await _firestoreService.decrementCredit(uid);
        debugPrint('[READ] credit decremented for uid=$uid');
      } catch (e) {
        debugPrint('[READ] error — decrementCredit failed: $e');
        _error = 'Kredi düşülemedi. Lütfen tekrar deneyin.';
        notifyListeners();
        return null;
      }

      debugPrint('[READ] request sent — tarot function call starting');
      String readingText;
      try {
        readingText = await _readingService.generateTarotReading(
          topic: topic,
          userNote: userNote,
          cardNames: cardNames,
        );
      } catch (e) {
        debugPrint('[READ] error — function call failed: $e');
        try {
          await _firestoreService.addCredits(uid, 1);
          debugPrint('[READ] credit refunded after function failure');
        } catch (_) {}
        _error = 'Yorum oluşturulamadı: $e';
        notifyListeners();
        return null;
      }

      debugPrint('[READ] function response received — tarot');
      debugPrint('[READ] result loaded — length=${readingText.length}');

      final reading = ReadingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        type: ReadingType.tarot,
        topic: topic,
        userNote: userNote,
        reading: readingText,
        tarotCards: cardNames,
        createdAt: DateTime.now(),
      );

      debugPrint('[READ] firestore write start');
      try {
        await _firestoreService.saveReading(reading);
        debugPrint('[READ] firestore write success');
        await loadReadings(uid);
      } catch (e) {
        debugPrint('[READ] firestore write failed: $e — using local');
        _readings = [reading, ..._readings];
        notifyListeners();
      }

      return reading;
    } catch (e) {
      debugPrint('[READ] error — startTarotReading unexpected: $e');
      _error = 'Tarot yorumu oluşturulamadı. Lütfen tekrar deneyin.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ReadingModel?> startPalmReading({
    required String uid,
    required String topic,
    required String userNote,
    required bool cameraConfirmed,
  }) async {
    _setLoading(true);
    _error = null;
    debugPrint('[READ] start — type=palm  uid=$uid');

    try {
      debugPrint('[PALM] cameraConfirmed = $cameraConfirmed');
      if (!cameraConfirmed) {
        _error = 'Kamera görüntüsü olmadan el falı başlatılamaz.';
        notifyListeners();
        return null;
      }

      try {
        await _firestoreService.decrementCredit(uid);
        debugPrint('[READ] credit decremented for uid=$uid');
      } catch (e) {
        debugPrint('[READ] error — decrementCredit failed: $e');
        _error = 'Kredi düşülemedi. Lütfen tekrar deneyin.';
        notifyListeners();
        return null;
      }

      debugPrint('[READ] request sent — palm function call starting');
      String readingText;
      try {
        readingText = await _readingService.generatePalmReading(
          uid: uid,
          topic: topic,
          userNote: userNote,
        );
      } catch (e) {
        debugPrint('[READ] error — function call failed: $e');
        try {
          await _firestoreService.addCredits(uid, 1);
          debugPrint('[READ] credit refunded after function failure');
        } catch (_) {}
        _error = 'Yorum oluşturulamadı: $e';
        notifyListeners();
        return null;
      }

      debugPrint('[READ] function response received — palm');
      debugPrint('[READ] result loaded — length=${readingText.length}');

      final reading = ReadingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        type: ReadingType.palm,
        topic: topic,
        userNote: userNote,
        reading: readingText,
        createdAt: DateTime.now(),
      );

      debugPrint('[READ] firestore write start');
      try {
        await _firestoreService.saveReading(reading);
        debugPrint('[READ] firestore write success');
        await loadReadings(uid);
      } catch (e) {
        debugPrint('[READ] firestore write failed: $e — using local');
        _readings = [reading, ..._readings];
        notifyListeners();
      }

      return reading;
    } catch (e) {
      debugPrint('[READ] error — startPalmReading unexpected: $e');
      _error = 'El falı yorumu oluşturulamadı. Lütfen tekrar deneyin.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReadings(String uid) async {
    try {
      final results = await _firestoreService.getUserReadings(uid);
      _readings = results;
      debugPrint('[History] loaded ${_readings.length} readings for uid=$uid');
    } catch (e) {
      debugPrint('[History] loadReadings error: $e');
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
