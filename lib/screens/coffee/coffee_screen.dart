import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';
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

    if (!_allUploaded) {
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.credits ?? 0),
              const SizedBox(height: 24),
              if (!hasCredits) _buildNoCreditsCard(),
              if (hasCredits) ...[
                _buildTopicSelector(),
                const SizedBox(height: 20),
                _buildNoteField(),
                const SizedBox(height: 24),
                _buildPhotoGrid(),
                const SizedBox(height: 12),
                _buildUploadProgress(),
                const SizedBox(height: 28),
                CoralButton(
                  text: _allUploaded ? 'Falımı Baktır' : 'Fotoğrafları Yükle',
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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Cinzel',
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: credits > 0
                ? AppTheme.primary.withOpacity(0.2)
                : AppTheme.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: credits > 0 ? AppTheme.primary : AppTheme.error,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.stars_rounded,
                size: 16,
                color: credits > 0 ? AppTheme.primary : AppTheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '$credits Hak',
                style: TextStyle(
                  color: credits > 0 ? AppTheme.primary : AppTheme.error,
                  fontFamily: 'Cinzel',
                  fontSize: 13,
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
          colors: [Color(0xFF3D1515), Color(0xFF2D1010)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            '🔒',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kahve falı için hak gerekli',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Cinzel',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '25 TL ile 1 fal hakkı satın al veya premium paketi incele.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          CoralButton(
            text: 'Satın Al',
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
            fontFamily: 'Cinzel',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.fortuneTopics.map((topic) {
            final selected = topic == _selectedTopic;
            return GestureDetector(
              onTap: () => setState(() => _selectedTopic = topic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.coralGradient : null,
                  color: selected ? null : AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : const Color(0xFF5D3030),
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durumunu Anlat (İsteğe Bağlı)',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: 'Cinzel',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 3,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
          decoration: const InputDecoration(
            hintText: 'Durumunuzu kısaca anlatın... (daha isabetli yorum için)',
            hintStyle: TextStyle(
                color: Color(0xFF7A5050), fontFamily: 'Cinzel', fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotoğrafları Yükle',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: 'Cinzel',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '1 telve tabağı + 3 fincan fotoğrafı yükleyin',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _photoSlot(
                  index: 0,
                  file: _saucerImage,
                  label: 'Telve Tabağı',
                  icon: '🍽️'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _photoSlot(
                  index: 1,
                  file: _cup1Image,
                  label: 'Fincan 1',
                  icon: '☕'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _photoSlot(
                  index: 2,
                  file: _cup2Image,
                  label: 'Fincan 2',
                  icon: '☕'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _photoSlot(
                  index: 3,
                  file: _cup3Image,
                  label: 'Fincan 3',
                  icon: '☕'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _photoSlot({
    required int index,
    required File? file,
    required String label,
    required String icon,
  }) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 130,
        decoration: BoxDecoration(
          color: file != null
              ? Colors.transparent
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null
                ? AppTheme.primary
                : const Color(0xFF5D3030),
            width: file != null ? 2 : 1,
          ),
          boxShadow: file != null
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cinzel',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.add_circle_outline,
                      color: AppTheme.primary, size: 20),
                ],
              ),
      ),
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
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Cinzel',
                fontSize: 13,
              ),
            ),
            Text(
              _allUploaded ? 'Hazır!' : 'Devam et',
              style: TextStyle(
                color: _allUploaded ? AppTheme.primary : AppTheme.textSecondary,
                fontFamily: 'Cinzel',
                fontSize: 13,
                fontWeight: _allUploaded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _uploadedCount / 4,
            backgroundColor: AppTheme.surface,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
