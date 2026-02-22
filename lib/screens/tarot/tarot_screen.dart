import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../models/tarot_card.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';
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
  final Set<int> _revealedIndices = {};
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
      setState(() {
        _selectedIndices.remove(index);
        _revealedIndices.remove(index);
      });
    } else if (_selectedIndices.length < _maxCards) {
      setState(() {
        _selectedIndices.add(index);
        _revealedIndices.add(index);
      });
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
    final selectedCards =
        sortedIndices.map((i) => _shuffledCards[i]).toList();

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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.credits ?? 0),
              const SizedBox(height: 24),
              if (!hasCredits)
                _buildNoCreditsCard()
              else ...[
                _buildTopicSelector(),
                const SizedBox(height: 20),
                _buildNoteField(),
                const SizedBox(height: 20),
                _buildSelectedCards(),
                const SizedBox(height: 20),
                _buildInstruction(),
                const SizedBox(height: 16),
                _buildCardGrid(),
                const SizedBox(height: 24),
                CoralButton(
                  text: _selectedIndices.length == _maxCards
                      ? 'Tarot Falımı Baktır'
                      : '${_selectedIndices.length} / $_maxCards Kart Seçildi',
                  onPressed: _selectedIndices.length == _maxCards
                      ? _startReading
                      : null,
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
          const Text('🔒', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Tarot falı için hak gerekli',
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
            '25 TL ile 1 fal hakkı satın al',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 14,
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
    );
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
                    color: selected ? Colors.white : AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 13,
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
      maxLines: 3,
      style: const TextStyle(
          color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
      decoration: const InputDecoration(
        labelText: 'Durumunu Anlat (İsteğe Bağlı)',
        hintText: 'Merak ettiğin konuyu kısaca anlat...',
        hintStyle: TextStyle(
            color: Color(0xFF7A5050), fontFamily: 'Cinzel', fontSize: 13),
      ),
    );
  }

  Widget _buildSelectedCards() {
    if (_selectedIndices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF5D3030)),
        ),
        child: const Text(
          '4 kart seç — önce kapalı görünecek, seçince açılacak',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    final sortedIndices = _selectedIndices.toList()..sort();
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedIndices.length,
        itemBuilder: (_, i) {
          final card = _shuffledCards[sortedIndices[i]];
          return Container(
            width: 72,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.coralGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(card.emoji,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  card.nameTr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cinzel',
                    fontSize: 8,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstruction() {
    return Text(
      '${_selectedIndices.length} / $_maxCards kart seçildi — aşağıdan 4 kart seç',
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontFamily: 'Cinzel',
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildCardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: _shuffledCards.length,
      itemBuilder: (_, i) => _buildTarotCard(i),
    );
  }

  Widget _buildTarotCard(int index) {
    final card = _shuffledCards[index];
    final isSelected = _selectedIndices.contains(index);
    final isRevealed = _revealedIndices.contains(index);
    final isDisabled =
        !isSelected && _selectedIndices.length >= _maxCards;

    return GestureDetector(
      onTap: isDisabled ? null : () => _toggleCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.coralGradient
              : isDisabled
                  ? const LinearGradient(
                      colors: [Color(0xFF1A0A0A), Color(0xFF0D0505)])
                  : AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : const Color(0xFF5D3030),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: isRevealed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(card.emoji,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    card.nameTr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cinzel',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: isDisabled
                      ? AppTheme.textSecondary.withOpacity(0.3)
                      : AppTheme.primary.withOpacity(0.6),
                  size: 22,
                ),
              ),
      ),
    );
  }
}
