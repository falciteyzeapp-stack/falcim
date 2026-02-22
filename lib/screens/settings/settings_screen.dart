import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';
import '../payment/payment_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return WaveBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚙️ Ayarlar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cinzel',
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileCard(user?.email ?? '', user?.displayName ?? '',
                  user?.credits ?? 0),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Hesap',
                items: [
                  _SettingsItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Fal Hakkı Satın Al',
                    subtitle: 'Günlük 25 TL / Premium paketler',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentScreen()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Şifre Değiştir',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Yasal',
                items: [
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    title: 'Kullanım Koşulları',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsScreen()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Gizlilik Politikası',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Destek',
                items: [
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    title: 'İletişim',
                    subtitle: 'meryemka3555@gmail.com',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),
              CoralButton(
                text: 'Çıkış Yap',
                outlined: true,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  child: const Text(
                    'Hesabı Sil',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Falcı Teyze v1.0.0',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String email, String name, int credits) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D1515), Color(0xFF2D1010)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cinzel',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Kullanıcı',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$credits',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Fal Hakkı',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: 'Cinzel',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4D2525)),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    onTap: e.value.onTap,
                    leading: Icon(e.value.icon,
                        color: AppTheme.primary, size: 22),
                    title: Text(
                      e.value.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                      ),
                    ),
                    subtitle: e.value.subtitle != null
                        ? Text(
                            e.value.subtitle!,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Cinzel',
                              fontSize: 12,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary, size: 14),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        color: Color(0xFF4D2525),
                        indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: 'Cinzel',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cinzel')),
          ),
          TextButton(
            onPressed: () async {
              final success =
                  await context.read<AuthProvider>().changePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                      );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Şifre başarıyla değiştirildi'
                          : context.read<AuthProvider>().error ??
                              'Hata oluştu',
                    ),
                    backgroundColor:
                        success ? AppTheme.primary : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Değiştir',
                style: TextStyle(
                    color: AppTheme.primary, fontFamily: 'Cinzel')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Hesabı Sil',
          style: TextStyle(
            color: AppTheme.error,
            fontFamily: 'Cinzel',
          ),
        ),
        content: const Text(
          'Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz silinecek.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cinzel',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontFamily: 'Cinzel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Sil',
                style: TextStyle(
                    color: AppTheme.error, fontFamily: 'Cinzel')),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
