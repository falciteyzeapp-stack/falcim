import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  List<ProductDetails> _products = [];
  bool _loading = true;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    _paymentService.listenToPurchases(
      uid,
      () {
        if (mounted) {
          context.read<AuthProvider>().refreshUser();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Satın alma başarılı! Hakkınız eklendi.'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      },
      (error) {
        if (mounted) {
          setState(() => _processingId = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadProducts() async {
    final products = await _paymentService.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
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
                    const Expanded(
                      child: Text(
                        '💫 Fal Hakkı Satın Al',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3D1515), Color(0xFF2D1010)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.gold.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('🔮', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              'Falcı Teyze\'ye Sor',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontFamily: 'Cinzel',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Her falda uzun, detaylı ve kişiye özel yorum',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontFamily: 'Cinzel',
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 28),
                      if (_loading)
                        const CircularProgressIndicator(
                            color: AppTheme.primary)
                      else if (_products.isEmpty)
                        ..._buildFallbackProducts()
                      else
                        ..._products.map((p) => _buildProductCard(p)),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          await _paymentService.restorePurchases();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Satın almalar geri yükleniyor...'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Satın Almaları Geri Yükle',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'Cinzel',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ödeme Apple/Google hesabınız üzerinden gerçekleşir.\nSatın alma işlemi tamamlandıktan sonra iade yapılmaz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cinzel',
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
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

  Widget _buildProductCard(ProductDetails product) {
    final isProcessing = _processingId == product.id;
    final isPremium = product.id.contains('premium');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4D2020),
                  Color(0xFF3D1515),
                ],
              )
            : null,
        color: isPremium ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? AppTheme.gold.withOpacity(0.5)
              : const Color(0xFF5D3030),
          width: isPremium ? 1.5 : 1,
        ),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: AppTheme.gold.withOpacity(0.1),
                  blurRadius: 16,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(
            isPremium ? '👑' : '⭐',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title.replaceAll(' (Falcı Teyze)', ''),
                  style: TextStyle(
                    color: isPremium ? AppTheme.gold : AppTheme.textPrimary,
                    fontFamily: 'Cinzel',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CoralButton(
            text: product.price,
            isLoading: isProcessing,
            width: 90,
            onPressed: isProcessing
                ? null
                : () async {
                    setState(() => _processingId = product.id);
                    await _paymentService.buyProduct(product);
                    if (mounted) setState(() => _processingId = null);
                  },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildFallbackProducts() {
    return [
      _buildFallbackCard(
        emoji: '⭐',
        title: '1 Fal Hakkı',
        description: 'Kahve veya Tarot falı baktır',
        price: '25 TL',
        isPremium: false,
      ),
      _buildFallbackCard(
        emoji: '👑',
        title: 'Haftalık Premium',
        description: '100 fal hakkı — 7 gün',
        price: '200 TL',
        isPremium: true,
      ),
      _buildFallbackCard(
        emoji: '🔮',
        title: 'Aylık Premium',
        description: '100 fal hakkı — 30 gün',
        price: '200 TL',
        isPremium: true,
      ),
    ];
  }

  Widget _buildFallbackCard({
    required String emoji,
    required String title,
    required String description,
    required String price,
    required bool isPremium,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF3D1515) : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? AppTheme.gold.withOpacity(0.4)
              : const Color(0xFF5D3030),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isPremium ? AppTheme.gold : AppTheme.textPrimary,
                    fontFamily: 'Cinzel',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.coralGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cinzel',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}
