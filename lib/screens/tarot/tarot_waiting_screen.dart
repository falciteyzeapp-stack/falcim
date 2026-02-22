import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../models/tarot_card.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../config/constants.dart';
import 'tarot_result_screen.dart';

class TarotWaitingScreen extends StatefulWidget {
  final List<TarotCard> cards;
  final String topic;
  final String userNote;

  const TarotWaitingScreen({
    super.key,
    required this.cards,
    required this.topic,
    required this.userNote,
  });

  @override
  State<TarotWaitingScreen> createState() => _TarotWaitingScreenState();
}

class _TarotWaitingScreenState extends State<TarotWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _remainingSeconds = AppConstants.waitingMinutes * 60;
  bool _generating = false;
  int _messageIndex = 0;

  static const List<String> _messages = [
    'Kartların enerjisi açılıyor...',
    'Falcı Teyze yorumluyor...',
    'Evrenin mesajları okunuyor...',
    'Semboller konuşuyor...',
    'Sabırlı ol...',
    'Kartlar sana ne söylüyor...',
    'Kader çarkı dönüyor...',
    'Gizem çözülüyor...',
    'Neredeyse hazır...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _messageIndex = (_messageIndex + 1) % _messages.length;
        } else {
          timer.cancel();
          _finishAndGenerate();
        }
      });
    });
  }

  Future<void> _finishAndGenerate() async {
    if (_generating) return;
    setState(() => _generating = true);

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final cardNames = widget.cards.map((c) => c.nameTr).toList();
    final reading = await context.read<ReadingProvider>().startTarotReading(
          uid: uid,
          topic: widget.topic,
          userNote: widget.userNote,
          cardNames: cardNames,
        );

    if (!mounted) return;

    if (reading != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TarotResultScreen(
            reading: reading,
            cards: widget.cards,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.cards.asMap().entries.map((e) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Transform.scale(
                          scale: 0.9 +
                              (_pulseController.value * 0.1) *
                                  (e.key.isEven ? 1 : -1).abs(),
                          child: Container(
                            width: 56,
                            height: 82,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              gradient: AppTheme.coralGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(
                                      0.2 + _pulseController.value * 0.2),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(e.value.emoji,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    e.value.nameTr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cinzel',
                                      fontSize: 7,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 40),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontFamily: 'Cinzel',
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'kaldı',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      _generating
                          ? 'Tarot yorumu hazırlanıyor...'
                          : _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_generating)
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
                          fontFamily: 'Cinzel',
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
