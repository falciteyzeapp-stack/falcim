import 'package:cloud_firestore/cloud_firestore.dart';

enum ReadingType { coffee, tarot }

class ReadingModel {
  final String id;
  final String userId;
  final ReadingType type;
  final String topic;
  final String userNote;
  final String reading;
  final List<String> imageUrls;
  final List<String> tarotCards;
  final DateTime createdAt;

  ReadingModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.topic,
    required this.userNote,
    required this.reading,
    this.imageUrls = const [],
    this.tarotCards = const [],
    required this.createdAt,
  });

  factory ReadingModel.fromMap(Map<String, dynamic> map, String id) {
    return ReadingModel(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] == 'coffee' ? ReadingType.coffee : ReadingType.tarot,
      topic: map['topic'] ?? '',
      userNote: map['userNote'] ?? '',
      reading: map['reading'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tarotCards: List<String>.from(map['tarotCards'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type == ReadingType.coffee ? 'coffee' : 'tarot',
      'topic': topic,
      'userNote': userNote,
      'reading': reading,
      'imageUrls': imageUrls,
      'tarotCards': tarotCards,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
