import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/reading_provider.dart';
import 'services/firestore_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';
import 'screens/legal/terms_screen.dart';

// Global IAP listener — ekran lifecycle'ından bağımsız
void _startGlobalIapListener() {
  InAppPurchase.instance.purchaseStream.listen((purchases) async {
    for (final purchase in purchases) {
      debugPrint('[GlobalIAP] status=${purchase.status} id=${purchase.productID}');
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // completePurchase — Google'a "aldım" bildir
        if (purchase.pendingCompletePurchase) {
          try {
            await InAppPurchase.instance.completePurchase(purchase);
          } catch (e) {
            debugPrint('[GlobalIAP] completePurchase error: $e');
          }
        }
        // Kredi ekle
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        if (uid.isNotEmpty) {
          try {
            await FirestoreService().addCredits(uid, 1);
            debugPrint('[GlobalIAP] ✅ credits +1 → $uid');
          } catch (e) {
            debugPrint('[GlobalIAP] addCredits error: $e');
            // Retry
            try {
              await Future.delayed(const Duration(seconds: 3));
              await FirestoreService().addCredits(uid, 1);
              debugPrint('[GlobalIAP] ✅ credits +1 retry → $uid');
            } catch (_) {}
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          try { await InAppPurchase.instance.completePurchase(purchase); } catch (_) {}
        }
      }
    }
  }, onError: (e) => debugPrint('[GlobalIAP] stream error: $e'));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
  };

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('[Firebase] init error: $e');
  }

  try {
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint('[intl] init error: $e');
  }

  // Global IAP listener kaldırıldı — PaymentScreen doğrudan yönetiyor
  // (duplicate subscription çakışmasını önlemek için)

  runApp(const FalcimApp());
}

class FalcimApp extends StatelessWidget {
  const FalcimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
      ],
      child: MaterialApp(
        title: 'Falcim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AppRoot(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/terms': (_) => const TermsScreen(),
          '/privacy': (_) => const PrivacyPolicyScreen(),
        },
      ),
    );
  }
}

/// Oturum yönetimi: AuthProvider'dan tek kaynak
class _AppRoot extends StatelessWidget {
  const _AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().status;

    if (authStatus == AuthStatus.uninitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF9A1010),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (authStatus == AuthStatus.authenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
