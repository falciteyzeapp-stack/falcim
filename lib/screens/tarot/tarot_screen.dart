import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../models/tarot_card.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';
import '../../widgets/premium_tarot_card.dart';
import '../../config/constants.dart';
import '../payment/payment_screen.dart';
import 'tarot_waiting_screen.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({super.key});

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  late List<TarotCard> _shuffledCards;
  final Set<int> _selectedIndices = {};
  String _selectedTopic = 'Genel';
  final _noteCtrl = TextEditingController();

  static const int _maxCards = 4;

  @override
  void initState() {
    super.initState();
    _shuffledCards = TarotCard.getShuffled();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _toggleCard(int index) {
    if (_selectedIndices.contains(index)) {
      setState(() => _selectedIndices.remove(index));
    } else if (_selectedIndices.length < _maxCards) {
      setState(() => _selectedIndices.add(index));
    }
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

    if (_selectedIndices.length < _maxCards) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 4 kart seçin'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final sortedIndices = _selectedIndices.toList()..sort();
    final selectedCards = sortedIndices.map((i) => _shuffledCards[i]).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TarotWaitingScreen(
          cards: selectedCards,
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
                const SizedBox(height: 16),
                _buildSelectedInfo(),
                const SizedBox(height: 12),
                _buildCardGrid(),
                const SizedBox(height: 20),
                CoralButton(
                  text: _selectedIndices.length == _maxCards
                      ? '✨ Tarot Falımı Baktır'
                      : '${_selectedIndices.length} / $_maxCards Kart Seçildi',
                  onPressed:
                      _selectedIndices.length == _maxCards ? _startReading : null,
                  icon: Icons.auto_awesome,
                ).animate().fadeIn(delay: 200.ms),
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
          '🃏 Tarot Falı',
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
            'Tarot falı için hak gerekli',
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
                    color: selected ? Colors.white : Colors.white.withOpacity(0.7),
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
        hintText: 'Merak ettiğin konuyu kısaca anlat...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
      ),
    );
  }

  Widget _buildSelectedInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedIndices.length == _maxCards
              ? AppTheme.gold.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedIndices.length == _maxCards
                ? Icons.check_circle
                : Icons.info_outline,
            color: _selectedIndices.length == _maxCards
                ? AppTheme.gold
                : Colors.white.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedIndices.length == _maxCards
                ? '4 kart seçildi — falını başlatabilirsin!'
                : '${_selectedIndices.length} / $_maxCards kart seçildi — aşağıdan 4 kart seç',
            style: TextStyle(
              color: _selectedIndices.length == _maxCards
                  ? AppTheme.gold
                  : Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.62,
      ),
      itemCount: _shuffledCards.length,
      itemBuilder: (_, i) {
        final card = _shuffledCards[i];
        final isSelected = _selectedIndices.contains(i);
        final isDisabled = !isSelected && _selectedIndices.length >= _maxCards;
        return PremiumTarotCard(
          emoji: card.emoji,
          name: card.nameTr,
          isSelected: isSelected,
          isDisabled: isDisabled,
          onTap: isDisabled ? null : () => _toggleCard(i),
        );
      },
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
