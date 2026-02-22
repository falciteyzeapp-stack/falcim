import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/reading_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ReadingModel reading;

  const HistoryDetailScreen({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final isCoffee = reading.type == ReadingType.coffee;
    return Scaffold(
      body: WaveBackground(
        animated: false,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        isCoffee ? '☕ Kahve Falı' : '🃏 Tarot Falı',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reading.imageUrls.isNotEmpty) _buildImages(),
                      if (reading.tarotCards.isNotEmpty) _buildCards(),
                      const SizedBox(height: 16),
                      _buildMeta(),
                      if (reading.userNote.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF5D3030)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Senin Notun',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Cinzel',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                reading.userNote,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Cinzel',
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: const Color(0xFF5D3030)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: AppTheme.gold, size: 18),
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
                      ),
                      const SizedBox(height: 20),
                      CoralButton(
                        text: 'Paylaş',
                        outlined: true,
                        icon: Icons.share_outlined,
                        onPressed: _share,
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

  Widget _buildImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yüklenen Fotoğraflar',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reading.imageUrls.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  reading.imageUrls[i],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.surface,
                    child: const Icon(Icons.image,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seçilen Kartlar',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reading.tarotCards.map((name) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cinzel',
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
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
          DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
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

  void _share() {
    Share.share(
      '🔮 Fal Yorumum - Falcı Teyze\n\nKonu: ${reading.topic}\n\n${reading.reading}\n\n🌙 Falcı Teyze uygulamasından',
    );
  }
}
