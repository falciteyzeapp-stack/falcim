import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final int credits;
  final bool freeCreditClaimed;
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.credits = 0,
    this.freeCreditClaimed = false,
    this.isPremium = false,
    this.premiumUntil,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      credits: map['krediler'] ?? 0,
      freeCreditClaimed: map['freeCreditClaimed'] ?? false,
      isPremium: map['isPremium'] ?? false,
      premiumUntil: map['premiumUntil'] != null
          ? (map['premiumUntil'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'krediler': credits,
      'freeCreditClaimed': freeCreditClaimed,
      'isPremium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? phoneNumber,
    int? credits,
    bool? freeCreditClaimed,
    bool? isPremium,
    DateTime? premiumUntil,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      credits: credits ?? this.credits,
      freeCreditClaimed: freeCreditClaimed ?? this.freeCreditClaimed,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      createdAt: createdAt,
    );
  }
}
