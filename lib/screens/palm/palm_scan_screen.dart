import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sparkle_background.dart';
import '../../widgets/coral_button.dart';
import '../payment/payment_screen.dart';
import 'palm_waiting_screen.dart';

class PalmScanScreen extends StatefulWidget {
  const PalmScanScreen({super.key});

  @override
  State<PalmScanScreen> createState() => _PalmScanScreenState();
}

class _PalmScanScreenState extends State<PalmScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _glowController;
  late AnimationController _pulseController;

  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _cameraPermissionDenied = false;

  bool _isScanning = false;
  int _scanProgress = 0;
  int _scanStepIndex = 0;
  String _selectedTopic = 'Genel';
  final _noteCtrl = TextEditingController();

  static const List<_ScanStep> _scanSteps = [
    _ScanStep(0, 'Kamera hazırlanıyor...', 5),
    _ScanStep(5, 'El algılanıyor... 🖐', 20),
    _ScanStep(20, 'Çizgiler analiz ediliyor...', 35),
    _ScanStep(35, 'Yaşam çizgisi inceleniyor... 🌿', 52),
    _ScanStep(52, 'Kalp çizgisi okunuyor... ❤️', 67),
    _ScanStep(67, 'Kader çizgisi yorumlanıyor... ⭐', 82),
    _ScanStep(82, 'Baş çizgisi analiz ediliyor... 💡', 93),
    _ScanStep(93, 'Son yorum hazırlanıyor... ✨', 100),
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraPermissionDenied = true);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _cameraController?.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _startScan() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if ((user.credits) <= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentScreen()),
      );
      return;
    }

    final cameraOk = _cameraInitialized && _cameraController != null;
    debugPrint('[PALM] camera initialized = $cameraOk');
    debugPrint('[PALM] camera permission denied = $_cameraPermissionDenied');

    if (!cameraOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera başlatılamadı. Lütfen kamera iznini verin ve tekrar deneyin.'),
          backgroundColor: Color(0xFFCC2020),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scanProgress = 0;
      _scanStepIndex = 0;
    });

    _runScanSequence();
  }

  Future<void> _runScanSequence() async {
    // Her adım arası ~6 saniye → 8 adım × 6s ≈ 50 saniye toplam tarama
    for (int stepIdx = 0; stepIdx < _scanSteps.length; stepIdx++) {
      final step = _scanSteps[stepIdx];
      final nextTarget = stepIdx < _scanSteps.length - 1
          ? _scanSteps[stepIdx + 1].startAt
          : 100;

      if (!mounted) return;
      setState(() => _scanStepIndex = stepIdx);

      // Her adımda yavaşça ilerleme
      for (int p = step.startAt; p < nextTarget; p++) {
        await Future.delayed(const Duration(milliseconds: 360));
        if (!mounted) return;
        setState(() => _scanProgress = p);
      }
    }

    if (!mounted) return;
    setState(() => _scanProgress = 100);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Kamera görüntüsü al — zorunlu
    final cameraStillOk = _cameraInitialized && _cameraController != null;
    debugPrint('[PALM] image exists = $cameraStillOk');

    if (!cameraStillOk) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamera görüntüsü alınamadı. Lütfen tekrar deneyin.'),
          backgroundColor: Color(0xFFCC2020),
        ),
      );
      return;
    }

    debugPrint('[PALM] hand detected = true (camera active, scan complete)');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PalmWaitingScreen(
          topic: _selectedTopic,
          userNote: _noteCtrl.text.trim(),
          cameraConfirmed: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hasCredits = (user?.credits ?? 0) > 0;

    return Scaffold(
      body: SparkleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(user?.credits ?? 0),
                const SizedBox(height: 20),
                if (!hasCredits)
                  _buildNoCreditsCard()
                else if (_isScanning)
                  _buildScanningView()
                else ...[
                  _buildTopicSelector(),
                  const SizedBox(height: 16),
                  _buildNoteField(),
                  const SizedBox(height: 24),
                  _buildCameraArea(),
                  const SizedBox(height: 24),
                  _buildInstructions(),
                  const SizedBox(height: 24),
                  CoralButton(
                    text: '🖐 El Taramasını Başlat',
                    onPressed: _startScan,
                    icon: Icons.back_hand_outlined,
                  ).animate().fadeIn(delay: 300.ms),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int credits) {
    return Row(
      children: [
        const Text(
          '🖐 El Falı',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: credits > 0
                ? AppTheme.gold.withOpacity(0.15)
                : AppTheme.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: credits > 0
                  ? AppTheme.gold.withOpacity(0.6)
                  : AppTheme.error.withOpacity(0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded,
                  size: 14,
                  color: credits > 0 ? AppTheme.gold : AppTheme.error),
              const SizedBox(width: 4),
              Text(
                '$credits Hak',
                style: TextStyle(
                  color: credits > 0 ? AppTheme.gold : AppTheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoCreditsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x88CC2020), Color(0x66881010)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'El falı için hak gerekli',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '25 TL ile 1 fal hakkı satın al',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 20),
          CoralButton(
            text: '25 TL — Fal Hakkı Al',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentScreen()),
            ),
            icon: Icons.shopping_bag_outlined,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTopicSelector() {
    final topics = ['Genel', 'Kader', 'Aşk', 'Sağlık', 'Kariyer'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Odaklanmak İstediğin Konu',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((topic) {
            final selected = topic == _selectedTopic;
            return GestureDetector(
              onTap: () => setState(() => _selectedTopic = topic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.coralGradient : null,
                  color:
                      selected ? null : Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppTheme.gold.withOpacity(0.6)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteCtrl,
      maxLines: 2,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: 'Durumunu Anlat (İsteğe Bağlı)',
        hintText: 'El hatlarında ne öğrenmek istiyorsun?',
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      ),
    );
  }

  Widget _buildCameraArea() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, __) {
        final glow = 0.4 + _glowController.value * 0.4;
        return Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black,
            border: Border.all(
              color: const Color(0xFF00FF88).withOpacity(0.4 + glow * 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(glow * 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Kamera önizlemesi veya fallback
                if (_cameraInitialized && _cameraController != null)
                  CameraPreview(_cameraController!)
                else if (_cameraPermissionDenied)
                  _buildCameraFallback()
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00FF88),
                      ),
                    ),
                  ),
                // Tarama animasyonu overlay
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (_, __) => CustomPaint(
                    painter: _PalmScanOverlayPainter(
                      progress: _scanController.value,
                      glowValue: _glowController.value,
                    ),
                  ),
                ),
                // Merkezdeki el ikonu (yarı şeffaf rehber)
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      final scale = 1.0 + _pulseController.value * 0.04;
                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.back_hand_outlined,
                          size: 100,
                          color: const Color(0xFF00FF88)
                              .withOpacity(0.18 + _pulseController.value * 0.1),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Avuç içini kameraya göster',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF00FF88).withOpacity(0.85),
                      fontSize: 13,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildCameraFallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF001A00),
            Colors.black,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _PalmScanOverlayPainter(
          progress: 0.5,
          glowValue: 0.5,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.back_hand_outlined,
                  size: 90,
                  color: const Color(0xFF00FF88).withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'Kamera izni gerekli',
                style: TextStyle(
                  color: const Color(0xFF00FF88).withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _instructionRow('🖐', 'Avuç içini kameraya göster'),
          const SizedBox(height: 8),
          _instructionRow('💡', 'İyi aydınlatılmış ortamda tara'),
          const SizedBox(height: 8),
          _instructionRow('⏱️', 'Yaklaşık 50 saniye sabit tut'),
          const SizedBox(height: 8),
          _instructionRow('✨', 'Kader, yaşam, kalp ve baş çizgileri okunacak'),
        ],
      ),
    );
  }

  Widget _instructionRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningView() {
    final currentStep = _scanStepIndex < _scanSteps.length
        ? _scanSteps[_scanStepIndex]
        : _scanSteps.last;

    return Column(
      children: [
        const SizedBox(height: 12),
        // Kamera + tarama overlay
        AnimatedBuilder(
          animation: _scanController,
          builder: (_, __) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFF00FF88)
                      .withOpacity(0.6 + _glowController.value * 0.3),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88)
                        .withOpacity(0.25 + _glowController.value * 0.2),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_cameraInitialized && _cameraController != null)
                      CameraPreview(_cameraController!)
                    else
                      Container(color: Colors.black),
                    CustomPaint(
                      painter: _ActiveScanPainter(
                        progress: _scanController.value,
                        scanProgress: _scanProgress / 100.0,
                        glowValue: _glowController.value,
                      ),
                    ),
                    // El ikonu üst üste
                    Center(
                      child: Icon(
                        Icons.back_hand,
                        size: 100,
                        color: const Color(0xFF00FF88)
                            .withOpacity(0.15 + _glowController.value * 0.1),
                      ),
                    ),
                    // El algılandı rozeti
                    if (_scanProgress >= 20)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF88).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    const Color(0xFF00FF88).withOpacity(0.5),
                              ),
                            ),
                            child: const Text(
                              '✓ El algılandı',
                              style: TextStyle(
                                color: Color(0xFF00FF88),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Adım mesajı
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF00FF88).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF00FF88).withOpacity(0.3)),
          ),
          child: Text(
            currentStep.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00FF88),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // İlerleme çubuğu
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _scanProgress / 100.0,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '%$_scanProgress tamamlandı',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        // Adım listesi
        _buildStepList(),
      ],
    );
  }

  Widget _buildStepList() {
    final steps = [
      'El algılanıyor',
      'Çizgiler analiz ediliyor',
      'Yaşam çizgisi',
      'Kalp çizgisi',
      'Kader çizgisi',
      'Baş çizgisi',
      'Son yorum hazırlanıyor',
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final done = _scanStepIndex > i + 1;
        final active = _scanStepIndex == i + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? const Color(0xFF00FF88)
                      : active
                          ? const Color(0xFF00FF88).withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: done || active
                        ? const Color(0xFF00FF88)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 12, color: Colors.black)
                    : active
                        ? const Center(
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00FF88),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : null,
              ),
              const SizedBox(width: 10),
              Text(
                steps[i],
                style: TextStyle(
                  color: done
                      ? const Color(0xFF00FF88)
                      : active
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ScanStep {
  final int startAt;
  final String message;
  final int endAt;
  const _ScanStep(this.startAt, this.message, this.endAt);
}

class _PalmScanOverlayPainter extends CustomPainter {
  final double progress;
  final double glowValue;

  _PalmScanOverlayPainter({required this.progress, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final scanY = progress * size.height;

    // Tarama çizgisi
    final linePaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.7 + glowValue * 0.3)
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);

    // Gradient band
    final gradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x0000FF88),
          Color.fromRGBO(0, 255, 136, 0.10 + glowValue * 0.06),
          const Color(0x0000FF88),
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 80));
    canvas.drawRect(
        Rect.fromLTWH(0, scanY - 40, size.width, 80), gradPaint);

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Köşe çerçeve
    final cornerPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const cs = 22.0;
    final corners = [
      [Offset(10, 10), Offset(10 + cs, 10), Offset(10, 10 + cs)],
      [
        Offset(size.width - 10, 10),
        Offset(size.width - 10 - cs, 10),
        Offset(size.width - 10, 10 + cs)
      ],
      [
        Offset(10, size.height - 10),
        Offset(10 + cs, size.height - 10),
        Offset(10, size.height - 10 - cs)
      ],
      [
        Offset(size.width - 10, size.height - 10),
        Offset(size.width - 10 - cs, size.height - 10),
        Offset(size.width - 10, size.height - 10 - cs)
      ],
    ];
    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], cornerPaint);
      canvas.drawLine(corner[0], corner[2], cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_PalmScanOverlayPainter old) =>
      old.progress != progress || old.glowValue != glowValue;
}

class _ActiveScanPainter extends CustomPainter {
  final double progress;
  final double scanProgress;
  final double glowValue;

  _ActiveScanPainter({
    required this.progress,
    required this.scanProgress,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawScanLine(canvas, size);
    if (scanProgress > 0.2) _drawPalmLines(canvas, size);
    _drawCorners(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  void _drawScanLine(Canvas canvas, Size size) {
    final y = progress * size.height;
    final p = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.8 + glowValue * 0.2)
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  void _drawPalmLines(Canvas canvas, Size size) {
    final lp = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(scanProgress * 0.65)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    // Yaşam çizgisi
    final life = Path()
      ..moveTo(size.width * 0.3, size.height * 0.82)
      ..quadraticBezierTo(
          size.width * 0.28, size.height * 0.55, size.width * 0.48, size.height * 0.28);
    canvas.drawPath(life, lp);

    // Kalp çizgisi
    final heart = Path()
      ..moveTo(size.width * 0.18, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.46, size.height * 0.36, size.width * 0.76, size.height * 0.44);
    canvas.drawPath(heart, lp);

    // Kader çizgisi
    final fate = Path()
      ..moveTo(size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.55, size.width * 0.48, size.height * 0.22);
    canvas.drawPath(fate, lp);

    // Baş çizgisi
    if (scanProgress > 0.5) {
      final head = Path()
        ..moveTo(size.width * 0.22, size.height * 0.55)
        ..quadraticBezierTo(
            size.width * 0.45, size.height * 0.52, size.width * 0.72, size.height * 0.58);
      canvas.drawPath(head, lp);
    }

    // Parlayan noktalar
    final dp = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(scanProgress * 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final dot in [
      Offset(size.width * 0.38, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.48),
      Offset(size.width * 0.6, size.height * 0.52),
    ]) {
      canvas.drawCircle(dot, 3.5, dp);
    }
  }

  void _drawCorners(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const cs = 22.0;
    final corners = [
      [Offset(8, 8), Offset(8 + cs, 8), Offset(8, 8 + cs)],
      [
        Offset(size.width - 8, 8),
        Offset(size.width - 8 - cs, 8),
        Offset(size.width - 8, 8 + cs)
      ],
      [
        Offset(8, size.height - 8),
        Offset(8 + cs, size.height - 8),
        Offset(8, size.height - 8 - cs)
      ],
      [
        Offset(size.width - 8, size.height - 8),
        Offset(size.width - 8 - cs, size.height - 8),
        Offset(size.width - 8, size.height - 8 - cs)
      ],
    ];
    for (final c in corners) {
      canvas.drawLine(c[0], c[1], p);
      canvas.drawLine(c[0], c[2], p);
    }
  }

  @override
  bool shouldRepaint(_ActiveScanPainter old) =>
      old.progress != progress ||
      old.scanProgress != scanProgress ||
      old.glowValue != glowValue;
}
