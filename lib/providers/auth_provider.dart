import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.authenticated;
      _user = await _firestoreService.getUser(firebaseUser.uid);
    }
    notifyListeners();
  }

  void _listenUserUpdates() {
    if (_user == null) return;
    _firestoreService.userStream(_user!.uid).listen((updatedUser) {
      _user = updatedUser;
      notifyListeners();
    });
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.authenticated;
      _listenUserUpdates();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _listenUserUpdates();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithGoogle();
      _status = AuthStatus.authenticated;
      _listenUserUpdates();
      return true;
    } catch (e) {
      _setError('Google ile giriş başarısız oldu.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithFacebook();
      _status = AuthStatus.authenticated;
      _listenUserUpdates();
      return true;
    } catch (e) {
      _setError('Facebook ile giriş başarısız oldu.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _authService.signInWithApple();
      _status = AuthStatus.authenticated;
      _listenUserUpdates();
      return true;
    } catch (e) {
      _setError('Apple ile giriş başarısız oldu.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void refreshUser() async {
    if (_user == null) return;
    _user = await _firestoreService.getUser(_user!.uid);
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email veya şifre yanlış';
      case 'email-already-in-use':
        return 'Bu e-postaya ait hesabınız var';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter girin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen bekleyin.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() => _clearError();
}
