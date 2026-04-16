import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> _getUserModel(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('[AuthService] _getUserModel error: $e');
    }
    return null;
  }

  // Firebase Auth başarılı olursa user döndür — Firestore hatası girişi engellemesin
  Future<UserModel> _createUserAndGrantFreeCredit(
    User firebaseUser, {
    String? phoneNumber,
  }) async {
    try {
      final existingUser = await _getUserModel(firebaseUser.uid);
      if (existingUser != null) {
        if (!existingUser.freeCreditClaimed) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(firebaseUser.uid)
              .update({'krediler': 1, 'freeCreditClaimed': true});
          return existingUser.copyWith(credits: 1, freeCreditClaimed: true);
        }
        return existingUser;
      }

      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        phoneNumber: phoneNumber,
        credits: 1,
        freeCreditClaimed: true,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(newUser.toMap());
      return newUser;
    } catch (e) {
      debugPrint('[AuthService] Firestore error (non-blocking): $e');
      // Firestore hatası girişi engellemesin — minimal user döndür
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Kullanıcı',
        credits: 1,
        freeCreditClaimed: true,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);
    return _createUserAndGrantFreeCredit(credential.user!);
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    return _createUserAndGrantFreeCredit(credential.user!);
  }

  Future<UserModel> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google girişi iptal edildi');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return _createUserAndGrantFreeCredit(userCredential.user!);
  }

  Future<UserModel> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook girişi iptal edildi veya başarısız oldu');
    }
    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
    final userCredential = await _auth.signInWithCredential(credential);
    return _createUserAndGrantFreeCredit(userCredential.user!);
  }

  Future<UserModel> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await _auth.signInWithCredential(oauthCredential);
    return _createUserAndGrantFreeCredit(userCredential.user!);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    try { await GoogleSignIn().signOut(); } catch (_) {}
    try { await FacebookAuth.instance.logOut(); } catch (_) {}
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
    }
    await _auth.currentUser?.delete();
  }
}
