import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                        'Kullanım Koşulları',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
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
                    _termsText,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
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

const String _termsText = '''
KULLANIM KOŞULLARI
Son güncelleme: Şubat 2026

Falcım uygulamasını kullanmadan önce bu koşulları dikkatlice okuyunuz.

1. HİZMET TANIMI

Falcım, kahve falı ve tarot kartı yorumları sunan bir eğlence uygulamasıdır. Sunulan tüm yorumlar tamamen eğlence amaçlıdır ve gerçek hayat kararlarında temel alınmamalıdır.

2. ÜYELİK KURALLARI

• Her e-posta adresi yalnızca bir hesap için kullanılabilir.
• Hesap bilgilerinin gizliliğini korumak kullanıcının sorumluluğundadır.
• Hesap başkasına devredilemez.

3. ÖDEME VE HAKLAR

• Her fal bakımı için 1 fal hakkı düşülür.
• Yeni kullanıcılara ilk kayıtta 1 ücretsiz fal hakkı tanınır. Bu hak hesap başına yalnızca bir kez geçerlidir.
• Fal hakkı paketleri:
  - Tekli: 25 TL — 1 fal hakkı
  - Haftalık Premium: 200 TL — 100 fal hakkı (7 gün)
  - Aylık Premium: 200 TL — 100 fal hakkı (30 gün)

4. İADE POLİTİKASI

Dijital içerik niteliğindeki fal hakkı alımları için ödeme tamamlandıktan sonra iade yapılmamaktadır. Yasal zorunluluklar saklıdır. Teknik sorun kaynaklı durumlarda destek ekibimizle iletişime geçiniz.

5. YASAK KULLANIM

Uygulamayı tersine mühendislik ile analiz etmek, otomatik araçlarla toplu istek göndermek ve başkalarının hesaplarına yetkisiz erişim sağlamak yasaktır.

6. SORUMLULUK SINIRLAMASI

Falcım, fal yorumlarının doğruluğu veya güvenilirliği konusunda garanti vermemektedir.

7. UYUŞMAZLIK ÇÖZÜMÜ

Uyuşmazlıklarda Türkiye Cumhuriyeti hukuku uygulanır.

8. İLETİŞİM

Sorularınız için: meryemka3555@gmail.com
''';
