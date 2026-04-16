import 'package:cloud_firestore/cloud_firestore.dart';

enum ReadingType { coffee, tarot, palm }

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
    ReadingType type;
    switch (map['type']) {
      case 'coffee':
        type = ReadingType.coffee;
        break;
      case 'tarot':
        type = ReadingType.tarot;
        break;
      default:
        type = ReadingType.palm;
    }
    return ReadingModel(
      id: id,
      userId: map['userId'] ?? '',
      type: type,
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
    String typeStr;
    switch (type) {
      case ReadingType.coffee:
        typeStr = 'coffee';
        break;
      case ReadingType.tarot:
        typeStr = 'tarot';
        break;
      case ReadingType.palm:
        typeStr = 'palm';
        break;
    }
    return {
      'userId': userId,
      'type': typeStr,
      'topic': topic,
      'userNote': userNote,
      'reading': reading,
      'imageUrls': imageUrls,
      'tarotCards': tarotCards,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
