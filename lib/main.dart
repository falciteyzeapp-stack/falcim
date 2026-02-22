import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/reading_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';
import 'screens/legal/terms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('tr_TR', null);
  runApp(const FalciTeyzApp());
}

class FalciTeyzApp extends StatelessWidget {
  const FalciTeyzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
      ],
      child: MaterialApp(
        title: 'Falcı Teyze',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/home': (_) => const _AuthGuard(child: HomeScreen()),
          '/terms': (_) => const TermsScreen(),
          '/privacy': (_) => const PrivacyPolicyScreen(),
        },
      ),
    );
  }
}

class _AuthGuard extends StatelessWidget {
  final Widget child;

  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.status == AuthStatus.unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
