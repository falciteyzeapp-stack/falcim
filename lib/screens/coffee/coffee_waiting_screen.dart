import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../services/notification_service.dart';
import '../../models/reading_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../config/constants.dart';
import 'coffee_result_screen.dart';

class CoffeeWaitingScreen extends StatefulWidget {
  final List<File> images;
  final String topic;
  final String userNote;

  const CoffeeWaitingScreen({
    super.key,
    required this.images,
    required this.topic,
    required this.userNote,
  });

  @override
  State<CoffeeWaitingScreen> createState() => _CoffeeWaitingScreenState();
}

class _CoffeeWaitingScreenState extends State<CoffeeWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _remainingSeconds = AppConstants.waitingMinutes * 60;
  int _messageIndex = 0;

  // Reading future — initState'de başlatılır, timer bitince await edilir
  Future<ReadingModel?>? _readingFuture;
  bool _navigating = false;

  static const List<String> _messages = [
    'Falcım fincana bakıyor...',
    'Enerjine odaklan...',
    'Telvede şekiller beliriyor...',
    'Falcım yorumluyor...',
    'Semboller okunuyor...',
    'Sabırlı ol, her şey hazırlanıyor...',
    'Kaderine yazılanlar ortaya çıkıyor...',
    'Fincanın sırrını çözüyorum...',
    'Neredeyse hazır...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Cloud Function'ı HEMEN arka planda başlat — timer bitmesini bekleme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startReadingInBackground();
      _startTimer();
    });
  }

  void _startReadingInBackground() {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      debugPrint('[READ] timeout — uid is null, cannot start reading');
      return;
    }
    debugPrint('[READ] start — background reading triggered immediately');
    _readingFuture = context.read<ReadingProvider>().startCoffeeReading(
          uid: uid,
          topic: widget.topic,
          userNote: widget.userNote,
          images: widget.images,
        );

    // React immediately when future resolves — don't wait for the 5-min timer
    _readingFuture!.then((reading) {
      debugPrint('[READ] future resolved early — reading=${reading != null ? "ok" : "null"}');
      if (!mounted || _navigating) return;
      _timer?.cancel();
      _navigating = true;
      setState(() {});
      if (reading != null) {
        debugPrint('[READ] navigating to result screen immediately');
        try { NotificationService().showReadingCompleteNotification().catchError((_) {}); } catch (_) {}
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CoffeeResultScreen(reading: reading),
          ),
        );
      } else {
        final err = context.read<ReadingProvider>().error ?? 'Yorum oluşturulamadı. Lütfen tekrar deneyin.';
        debugPrint('[READ] error — $err');
        _showError(err);
      }
    }).catchError((e) {
      debugPrint('[READ] future catchError — $e');
      if (!mounted || _navigating) return;
      _timer?.cancel();
      _navigating = true;
      _showError('Hata: $e');
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = (AppConstants.waitingMinutes * 60) - _remainingSeconds + 1;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, AppConstants.waitingMinutes * 60);
        _messageIndex = (elapsed ~/ 8) % _messages.length;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onTimerDone();
      }
    });
  }

  Future<void> _onTimerDone() async {
    if (_navigating) return;
    _navigating = true;
    debugPrint('[READ] timeout — timer done, awaiting reading future');

    if (_readingFuture == null) {
      debugPrint('[READ] error — readingFuture is null');
      _showError();
      return;
    }

    ReadingModel? reading;
    String? readingError;
    try {
      reading = await _readingFuture;
      debugPrint('[READ] result loaded — reading=${reading != null ? "ok" : "null"}');
    } catch (e) {
      readingError = '$e';
      debugPrint('[READ] error — awaiting readingFuture: $e');
    }

    if (!mounted) return;

    if (reading != null) {
      try {
        await NotificationService().showReadingCompleteNotification();
      } catch (_) {}
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CoffeeResultScreen(reading: reading!),
        ),
      );
    } else {
      final err = readingError ?? context.read<ReadingProvider>().error ?? 'Yorum oluşturulamadı. Lütfen tekrar deneyin.';
      _showError(err);
    }
  }

  void _showError([String? message]) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Bir hata oluştu. Lütfen tekrar deneyin.'),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isGenerating => _remainingSeconds <= 0 || _navigating;

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: 0.9 + (_pulseController.value * 0.1),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF5D2020), Color(0xFF3D1010)],
                          ),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(
                                0.5 + _pulseController.value * 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(
                                  0.2 + _pulseController.value * 0.3),
                              blurRadius: 30 + _pulseController.value * 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('☕', style: TextStyle(fontSize: 64)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 10),
                  const Text(
                    'kaldı',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      _isGenerating
                          ? 'Yorum hazırlanıyor...'
                          : _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_isGenerating)
                    const CircularProgressIndicator(color: AppTheme.primary)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Uygulamayı kapatma, falın hazırlanıyor...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
