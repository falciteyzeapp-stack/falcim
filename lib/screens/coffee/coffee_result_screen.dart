import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/reading_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class CoffeeResultScreen extends StatelessWidget {
  final ReadingModel reading;

  const CoffeeResultScreen({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
        animated: false,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reading.imageUrls.isNotEmpty) _buildImages(),
                      const SizedBox(height: 20),
                      _buildMeta(),
                      const SizedBox(height: 24),
                      _buildReadingCard(),
                      const SizedBox(height: 24),
                      CoralButton(
                        text: 'Paylaş',
                        outlined: true,
                        icon: Icons.share_outlined,
                        onPressed: () => _share(),
                      ),
                      const SizedBox(height: 12),
                      CoralButton(
                        text: 'Ana Sayfaya Dön',
                        onPressed: () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.popUntil(
                context, (route) => route.isFirst),
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.textPrimary),
          ),
          const Expanded(
            child: Text(
              '☕ Kahve Falınız',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: 'Cinzel',
              ),
            ),
          ),
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined,
                color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reading.imageUrls.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              reading.imageUrls[i],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: AppTheme.surface,
                child: const Icon(Icons.image, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: Text(
            reading.topic,
            style: const TextStyle(
              color: AppTheme.primary,
              fontFamily: 'Cinzel',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('dd MMM yyyy, HH:mm', 'tr_TR')
              .format(reading.createdAt),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5D3030)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'Falcı Teyze\'nin Yorumu',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontFamily: 'Cinzel',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF5D3030)),
          const SizedBox(height: 16),
          Text(
            reading.reading,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontFamily: 'Cinzel',
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  void _share() {
    Share.share(
      '☕ Kahve Falcı Teyze\'nin Yorumu\n\nKonu: ${reading.topic}\n\n${reading.reading}\n\n🔮 Falcı Teyze uygulamasından',
    );
  }
}
