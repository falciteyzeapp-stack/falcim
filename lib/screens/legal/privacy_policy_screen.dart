import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Expanded(
                      child: Text(
                        'Gizlilik Politikası',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
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
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    _privacyText,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _privacyText = '''
GİZLİLİK POLİTİKASI
Son güncelleme: Şubat 2026

Falcı Teyze uygulamasını kullandığınız için teşekkür ederiz.

1. TOPLANAN VERİLER

Kişisel Bilgiler:
• E-posta adresi (hesap oluşturma ve giriş için)
• Ad soyad (profil için, isteğe bağlı)

Kullanım Verileri:
• Uygulama içi işlemler (fal geçmişi)
• Yüklenen fotoğraflar (kahve falı için)
• Satın alma geçmişi ve kredi bakiyesi

2. VERİLERİN KULLANIMI

• Hesap oluşturma, doğrulama ve güvenliği sağlama
• Fal yorumlarının oluşturulması ve saklanması
• Satın alma işlemlerinin doğrulanması

3. ÜÇÜNCÜ TARAF HİZMETLER

• Firebase (Google) — kimlik doğrulama ve veritabanı
• Apple/Google Play — uygulama içi satın alma
• OpenAI — fal yorumu oluşturma (anonim)

4. VERİ SAKLAMA

Hesabınız aktif olduğu sürece verileriniz saklanır. Hesabınızı sildiğinizde tüm veriler kalıcı olarak silinir.

5. VERİ GÜVENLİĞİ

Firebase altyapısında şifrelenmiş şekilde saklanır. SSL/TLS şifrelemesi kullanılır.

6. KULLANICI HAKLARI

• Verilerinize erişim talep etme
• Verilerinizin düzeltilmesini isteme
• Hesabınızı ve tüm verilerinizi silme

7. ÇOCUKLARIN GİZLİLİĞİ

Uygulama 18 yaş altı bireylere yönelik değildir.

8. İLETİŞİM

Sorularınız için: meryemka3555@gmail.com
''';
