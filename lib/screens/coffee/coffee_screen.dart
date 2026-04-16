import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';
import '../../widgets/premium_tarot_card.dart';
import '../../config/constants.dart';
import '../payment/payment_screen.dart';
import 'coffee_waiting_screen.dart';

class CoffeeScreen extends StatefulWidget {
  const CoffeeScreen({super.key});

  @override
  State<CoffeeScreen> createState() => _CoffeeScreenState();
}

class _CoffeeScreenState extends State<CoffeeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _saucerImage;
  File? _cup1Image;
  File? _cup2Image;
  File? _cup3Image;
  String _selectedTopic = 'Genel';
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  int get _uploadedCount {
    int c = 0;
    if (_saucerImage != null) c++;
    if (_cup1Image != null) c++;
    if (_cup2Image != null) c++;
    if (_cup3Image != null) c++;
    return c;
  }

  bool get _allUploaded => _uploadedCount == 4;

  Future<void> _pickImage(int slot) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (xFile == null) return;
    final file = File(xFile.path);
    setState(() {
      switch (slot) {
        case 0:
          _saucerImage = file;
          break;
        case 1:
          _cup1Image = file;
          break;
        case 2:
          _cup2Image = file;
          break;
        case 3:
          _cup3Image = file;
          break;
      }
    });
  }

  void _startReading() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if ((user.credits) <= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentScreen()),
      );
      return;
    }

    debugPrint('[COFFEE] selected images count = $_uploadedCount');
    final analysisValid = _allUploaded &&
        [_saucerImage, _cup1Image, _cup2Image, _cup3Image]
            .every((f) => f != null && f.existsSync());
    debugPrint('[COFFEE] analysis valid = $analysisValid');

    if (!analysisValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 4 fotoğrafı da yükleyin (1 telve tabağı + 3 fincan)'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoffeeWaitingScreen(
          images: [_saucerImage!, _cup1Image!, _cup2Image!, _cup3Image!],
          topic: _selectedTopic,
          userNote: _noteCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hasCredits = (user?.credits ?? 0) > 0;

    return WaveBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.credits ?? 0),
              const SizedBox(height: 20),
              if (!hasCredits)
                _buildNoCreditsCard()
              else ...[
                _buildTopicSelector(),
                const SizedBox(height: 16),
                _buildNoteField(),
                const SizedBox(height: 20),
                _buildPhotoSection(),
                const SizedBox(height: 12),
                _buildUploadProgress(),
                const SizedBox(height: 24),
                CoralButton(
                  text: _allUploaded
                      ? '☕ Kahve Falımı Baktır'
                      : '$_uploadedCount / 4 Fotoğraf Yüklendi',
                  onPressed: _allUploaded ? _startReading : null,
                  icon: Icons.auto_awesome,
                ).animate().fadeIn(delay: 300.ms),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int credits) {
    return Row(
      children: [
        const Text(
          '☕ Kahve Falı',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        _CreditsChip(credits: credits),
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
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withOpacity(0.1),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Kahve falı için hak gerekli',
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
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fal Konusu',
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
          children: AppConstants.fortuneTopics.map((topic) {
            final selected = topic == _selectedTopic;
            return GestureDetector(
              onTap: () => setState(() => _selectedTopic = topic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.coralGradient : null,
                  color: selected ? null : Colors.black.withOpacity(0.3),
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
        hintText: 'Durumunuzu kısaca anlatın... (daha isabetli yorum için)',
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotoğrafları Yükle',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1 telve tabağı + 3 fincan fotoğrafı yükleyin',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlowPhotoSlot(
                label: 'Telve Tabağı',
                icon: '🍽️',
                hasImage: _saucerImage != null,
                onTap: () => _pickImage(0),
                child: _saucerImage != null
                    ? _imageWithCheck(_saucerImage!)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlowPhotoSlot(
                label: 'Fincan 1',
                icon: '☕',
                hasImage: _cup1Image != null,
                onTap: () => _pickImage(1),
                child:
                    _cup1Image != null ? _imageWithCheck(_cup1Image!) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlowPhotoSlot(
                label: 'Fincan 2',
                icon: '☕',
                hasImage: _cup2Image != null,
                onTap: () => _pickImage(2),
                child:
                    _cup2Image != null ? _imageWithCheck(_cup2Image!) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlowPhotoSlot(
                label: 'Fincan 3',
                icon: '☕',
                hasImage: _cup3Image != null,
                onTap: () => _pickImage(3),
                child:
                    _cup3Image != null ? _imageWithCheck(_cup3Image!) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imageWithCheck(File file) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(file, fit: BoxFit.cover),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_uploadedCount / 4 fotoğraf yüklendi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            Text(
              _allUploaded ? '✓ Hazır!' : 'Devam et',
              style: TextStyle(
                color: _allUploaded ? AppTheme.gold : Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontWeight:
                    _allUploaded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _uploadedCount / 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _allUploaded ? AppTheme.gold : AppTheme.primary,
            ),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _CreditsChip extends StatelessWidget {
  final int credits;
  const _CreditsChip({required this.credits});

  @override
  Widget build(BuildContext context) {
    final hasCredits = credits > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasCredits
            ? AppTheme.gold.withOpacity(0.15)
            : AppTheme.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCredits
              ? AppTheme.gold.withOpacity(0.6)
              : AppTheme.error.withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 14,
            color: hasCredits ? AppTheme.gold : AppTheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '$credits Hak',
            style: TextStyle(
              color: hasCredits ? AppTheme.gold : AppTheme.error,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
