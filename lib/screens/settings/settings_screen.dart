import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileCard(context, user?.email ?? '', user?.displayName ?? '', user?.credits ?? 0),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Hesap',
                items: [
                  _SettingsItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Fal Hakkı Satın Al',
                    subtitle: '25 TL / fal',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PaymentScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_reset_outlined,
                    title: 'Şifre Sıfırla',
                    subtitle: 'E-posta ile sıfırlama bağlantısı gönder',
                    onTap: () => _showResetPasswordDialog(context, user?.email ?? ''),
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
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TermsScreen())),
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Gizlilik Politikası',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Destek',
                items: [
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    title: 'İletişim & Şikayet',
                    subtitle: 'meryemka3555@gmail.com',
                    onTap: () => _openContactEmail(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              CoralButton(
                text: 'Çıkış Yap',
                outlined: true,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  final nav = Navigator.of(context);
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (nav.mounted) {
                      nav.pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  } catch (e) {
                    debugPrint('[Logout] error: $e');
                    if (nav.mounted) {
                      nav.pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteAccountDialog(context),
                  child: const Text('Hesabı Sil',
                      style: TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Falcım v1.0.9',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openContactEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'meryemka3555@gmail.com',
      queryParameters: {
        'subject': 'Falcım Uygulaması - Bildirim / Şikayet',
        'body': 'Merhaba,\n\nUygulama hakkında bildirmek istediğim:\n\n',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildProfileCard(BuildContext context, String email, String name, int credits) {
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
          GestureDetector(
            onTap: () => _showEditNameDialog(context, name),
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF8A80), AppTheme.primary],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 1.5),
                    ),
                    child: const Icon(Icons.edit, size: 11, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : 'Kullanıcı',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(context, name),
                      child: const Icon(Icons.edit_outlined,
                          color: AppTheme.textSecondary, size: 16),
                    ),
                  ],
                ),
                Text(
                  email,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$credits',
                style: const TextStyle(
                    color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text('Fal Hakkı',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('İsim Güncelle',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Görünen İsim'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              await auth.updateDisplayName(ctrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İsim güncellendi'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            },
            child: const Text('Kaydet',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, String email) {
    final emailCtrl = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Şifre Sıfırla',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-posta adresinize şifre sıfırlama bağlantısı göndereceğiz.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              style: const TextStyle(fontFamily: null, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<AuthProvider>()
                  .sendPasswordResetEmail(emailCtrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '✅ Şifre sıfırlama e-postası gönderildi'
                        : '❌ Hata oluştu. E-postayı kontrol edin.'),
                    backgroundColor:
                        success ? AppTheme.primary : AppTheme.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Gönder',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 0.5),
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
                    leading: Icon(e.value.icon, color: AppTheme.primary, size: 22),
                    title: Text(e.value.title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14)),
                    subtitle: e.value.subtitle != null
                        ? Text(e.value.subtitle!,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12))
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary, size: 14),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFF4D2525), indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Hesabı Sil',
            style: TextStyle(color: AppTheme.error)),
        content: const Text(
          'Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz silinecek.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint('[DeleteAccount] error: $e');
              }
            },
            child: const Text('Sil', style: TextStyle(color: AppTheme.error)),
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
