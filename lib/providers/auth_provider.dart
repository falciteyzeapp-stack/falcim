import 'dart:async';
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
  StreamSubscription<UserModel?>? _userStreamSub;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    final cachedUser = FirebaseAuth.instance.currentUser;
    if (cachedUser != null) {
      _status = AuthStatus.authenticated;
      _startUserStream(cachedUser.uid);
    }

    _authService.authStateChanges.listen(_onAuthStateChanged);

    Future.delayed(const Duration(seconds: 5), () {
      if (_status == AuthStatus.uninitialized) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _stopUserStream();
      } else {
        _status = AuthStatus.authenticated;
        _startUserStream(firebaseUser.uid);
      }
    } catch (e) {
      debugPrint('[AuthProvider] _onAuthStateChanged error: $e');
    }
    notifyListeners();
  }

  /// Firestore real-time stream — credits dahil her değişiklik anında yansır
  void _startUserStream(String uid) {
    _stopUserStream();
    _userStreamSub = _firestoreService.userStream(uid).listen(
      (updatedUser) {
        if (updatedUser != null) {
          _user = updatedUser;
          debugPrint('[AuthProvider] credits=${updatedUser.credits}');
          notifyListeners();
        }
      },
      onError: (e) => debugPrint('[AuthProvider] userStream error: $e'),
    );
  }

  void _stopUserStream() {
    _userStreamSub?.cancel();
    _userStreamSub = null;
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
      if (_user != null) _startUserStream(_user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Kayıt sırasında hata oluştu.');
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
      if (_user != null) _startUserStream(_user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Giriş sırasında hata oluştu.');
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
      if (_user != null) _startUserStream(_user!.uid);
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
      if (_user != null) _startUserStream(_user!.uid);
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
      if (_user != null) _startUserStream(_user!.uid);
      return true;
    } catch (e) {
      _setError('Apple ile giriş başarısız oldu.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDisplayName(String name) async {
    if (_user == null) return;
    try {
      await _firestoreService.updateUserDisplayName(_user!.uid, name);
      _user = _user!.copyWith(displayName: name);
      notifyListeners();
    } catch (_) {}
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
    _stopUserStream();
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Ödeme sonrası krediyi anında bellekte güncelle — stream bekleme yok
  void forceSetCredits(int credits) {
    final uid = _user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    _user = (_user ?? UserModel(
      uid: uid,
      email: FirebaseAuth.instance.currentUser?.email ?? '',
      displayName: FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı',
      credits: 0,
      freeCreditClaimed: true,
      createdAt: DateTime.now(),
    )).copyWith(credits: credits);
    debugPrint('[AuthProvider] forceSetCredits → $credits');
    notifyListeners();
  }

  void refreshUser() {
    final uid = _user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _startUserStream(uid);
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
