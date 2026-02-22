import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../models/reading_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ReadingProvider>().loadReadings(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WaveBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '📜 Fal Geçmişi',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cinzel',
                ),
              ),
            ),
            Expanded(
              child: Consumer<ReadingProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (provider.readings.isEmpty) {
                    return _buildEmpty();
                  }
                  return RefreshIndicator(
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    onRefresh: () async {
                      final uid =
                          context.read<AuthProvider>().user?.uid;
                      if (uid != null) {
                        await context
                            .read<ReadingProvider>()
                            .loadReadings(uid);
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: provider.readings.length,
                      itemBuilder: (_, i) =>
                          _buildItem(context, provider.readings[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📜', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Henüz fal geçmişin yok',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk falını baktırdıktan sonra burada görünecek',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, ReadingModel reading) {
    final isCoffee = reading.type == ReadingType.coffee;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(reading: reading),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4D2525)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isCoffee ? '☕' : '🃏',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCoffee ? 'Kahve Falı' : 'Tarot Falı',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'Cinzel',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reading.topic,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontFamily: 'Cinzel',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                        .format(reading.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cinzel',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
