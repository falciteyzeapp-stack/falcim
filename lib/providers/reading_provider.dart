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
    try {
      final readingId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrls =
          await _firestoreService.uploadImages(uid, images, readingId);
      await _firestoreService.decrementCredit(uid);
      final readingText = await _readingService.generateCoffeeReading(
        topic: topic,
        userNote: userNote,
      );
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
      await _firestoreService.saveReading(reading);
      await loadReadings(uid);
      return reading;
    } catch (e) {
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
    try {
      await _firestoreService.decrementCredit(uid);
      final readingText = await _readingService.generateTarotReading(
        topic: topic,
        userNote: userNote,
        cardNames: cardNames,
      );
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
      await _firestoreService.saveReading(reading);
      await loadReadings(uid);
      return reading;
    } catch (e) {
      _error = 'Tarot yorumu oluşturulamadı. Lütfen tekrar deneyin.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReadings(String uid) async {
    _setLoading(true);
    try {
      _readings = await _firestoreService.getUserReadings(uid);
    } catch (e) {
      _error = 'Geçmiş yüklenemedi.';
    } finally {
      _setLoading(false);
    }
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
