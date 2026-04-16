import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/reading_model.dart';
import '../../models/tarot_card.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class TarotResultScreen extends StatelessWidget {
  final ReadingModel reading;
  final List<TarotCard> cards;

  const TarotResultScreen({
    super.key,
    required this.reading,
    required this.cards,
  });

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
                      _buildCardRow(),
                      const SizedBox(height: 20),
                      _buildMeta(),
                      const SizedBox(height: 24),
                      _buildReadingCard(),
                      const SizedBox(height: 24),
                      CoralButton(
                        text: 'Paylaş',
                        outlined: true,
                        icon: Icons.share_outlined,
                        onPressed: _share,
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
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.textPrimary),
          ),
          const Expanded(
            child: Text(
              '🃏 Tarot Falınız',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
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

  Widget _buildCardRow() {
    final positions = ['Geçmiş', 'Şimdi', 'Gelecek', 'Sonuç'];
    return SizedBox(
      height: 120,
      child: Row(
        children: cards.asMap().entries.map((e) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.coralGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.value.emoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    e.value.nameTr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    positions[e.key],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 7,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
          )
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
                'Falcım\'nin Tarot Yorumu',
                style: TextStyle(
                  color: AppTheme.gold,
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
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  void _share() {
    final cardNames = cards.map((c) => c.nameTr).join(', ');
    Share.share(
      '🃏 Tarot Falı - Falcım\n\nKartlar: $cardNames\nKonu: ${reading.topic}\n\n${reading.reading}\n\n🔮 Falcım uygulamasından',
    );
  }
}
