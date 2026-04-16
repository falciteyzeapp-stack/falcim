import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../models/reading_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sparkle_background.dart';
import 'palm_result_screen.dart';

class PalmWaitingScreen extends StatefulWidget {
  final String topic;
  final String userNote;
  final bool cameraConfirmed;

  const PalmWaitingScreen({
    super.key,
    required this.topic,
    required this.userNote,
    this.cameraConfirmed = false,
  });

  @override
  State<PalmWaitingScreen> createState() => _PalmWaitingScreenState();
}

class _PalmWaitingScreenState extends State<PalmWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Timer _timer;
  int _secondsLeft = 240;
  int _messageIndex = 0;

  Future<ReadingModel?>? _readingFuture;
  bool _navigating = false;

  static const List<String> _messages = [
    'El hatların okunuyor... 🖐',
    'Kader çizgisi analiz ediliyor... ⭐',
    'Yaşam enerjin ölçülüyor... 🌿',
    'Kalp çizgisi inceleniyor... ❤️',
    'Baş çizgisi yorumlanıyor... 💡',
    'Avuç içindeki gizli işaretler görünüyor... 🔮',
    'Çizgiler arasındaki bağlantılar kuruluyor... 🌙',
    'Kişisel enerji haritası çıkarılıyor... ✨',
    'Falcım derin analizini tamamlıyor... 🌟',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startReadingInBackground();
      _startTimer();
    });
  }

  void _startReadingInBackground() {
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    if (uid.isEmpty) return;
    debugPrint('[READ] start — background palm reading triggered immediately');
    debugPrint('[PALM] cameraConfirmed = ${widget.cameraConfirmed}');
    _readingFuture = context.read<ReadingProvider>().startPalmReading(
          uid: uid,
          topic: widget.topic,
          userNote: widget.userNote,
          cameraConfirmed: widget.cameraConfirmed,
        );
  }

  void _startTimer() {
    int elapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      elapsed++;
      setState(() {
        _secondsLeft = (240 - elapsed).clamp(0, 240);
        _messageIndex = (elapsed ~/ 8) % _messages.length;
      });
      if (_secondsLeft <= 0) {
        t.cancel();
        _onTimerDone();
      }
    });
  }

  Future<void> _onTimerDone() async {
    if (_navigating) return;
    _navigating = true;
    debugPrint('[READ] timeout — timer done, awaiting palm future');

    ReadingModel? reading;
    try {
      reading = await _readingFuture;
      debugPrint('[READ] result loaded — palm=${reading != null ? "ok" : "null"}');
    } catch (e) {
      debugPrint('[READ] error — $e');
    }

    if (!mounted) return;

    if (reading != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PalmResultScreen(
            reading: reading!.reading,
            topic: widget.topic,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: Color(0xFFCC2020),
        ),
      );
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String get _timeDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SparkleBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (_, __) => Transform.rotate(
                      angle: _spinController.value * 2 * 3.14159,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              Color(0x00FF4444),
                              Color(0xFFFF4444),
                              Color(0x00FF4444),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '🖐',
                    style: TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _messages[_messageIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _timeDisplay,
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Falcım elini okuyor...\nSabırlı ol...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      height: 1.6,
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
