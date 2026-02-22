import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/reading_model.dart';
import '../config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) return UserModel.fromMap(doc.data()!, uid);
    return null;
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, uid) : null);
  }

  Future<bool> hasEnoughCredits(String uid) async {
    final user = await getUser(uid);
    return (user?.credits ?? 0) > 0;
  }

  Future<void> decrementCredit(String uid) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'credits': FieldValue.increment(-1)});
  }

  Future<void> addCredits(String uid, int amount) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'credits': FieldValue.increment(amount)});
  }

  Future<void> setPremium(String uid, DateTime until) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      'isPremium': true,
      'premiumUntil': Timestamp.fromDate(until),
      'credits': FieldValue.increment(100),
    });
  }

  Future<List<String>> uploadImages(
    String uid,
    List<File> images,
    String readingId,
  ) async {
    final urls = <String>[];
    for (int i = 0; i < images.length; i++) {
      final ref = _storage
          .ref()
          .child('readings/$uid/$readingId/image_$i.jpg');
      final task = await ref.putFile(images[i]);
      final url = await task.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<String> saveReading(ReadingModel reading) async {
    final doc = await _firestore
        .collection(AppConstants.readingsCollection)
        .add(reading.toMap());
    return doc.id;
  }

  Future<List<ReadingModel>> getUserReadings(String uid) async {
    final snapshot = await _firestore
        .collection(AppConstants.readingsCollection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ReadingModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<ReadingModel?> getReading(String readingId) async {
    final doc = await _firestore
        .collection(AppConstants.readingsCollection)
        .doc(readingId)
        .get();
    if (doc.exists) return ReadingModel.fromMap(doc.data()!, doc.id);
    return null;
  }
}
