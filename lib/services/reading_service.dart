import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ReadingService {
  Future<String> generateCoffeeReading({
    required String topic,
    required String userNote,
  }) async {
    final prompt = _buildCoffeePrompt(topic, userNote);
    return _callOpenAI(prompt);
  }

  Future<String> generateTarotReading({
    required String topic,
    required String userNote,
    required List<String> cardNames,
  }) async {
    final prompt = _buildTarotPrompt(topic, userNote, cardNames);
    return _callOpenAI(prompt);
  }

  String _buildCoffeePrompt(String topic, String userNote) {
    return '''Sen deneyimli ve sezgisel bir Türk kahve falcısısın. 
Kullanıcının fincanına derin bir şekilde baktın ve şimdi ona çok ayrıntılı, gerçekçi ve inandırıcı bir kahve falı yorumu yapacaksın.

Konu: $topic
Kullanıcının anlattığı durum: ${userNote.isNotEmpty ? userNote : 'Genel bir bakış isteniyor'}

Yorumunu aşağıdaki yapıda yap (her bölüm en az 3-4 paragraf olsun):

🔮 GENEL ENERJİ VE ATMOSFER
Fincanın genel enerjisini, atmosferini ve ilk izlenimlerini anlat. Kahve telvesindeki şekilleri ve sembolleri imgele ve yorumla.

💫 $topic KONUSUNDA DETAYLI BAKIŞ
Kullanıcının belirttiği konuya özel, çok detaylı bir yorum yap. En az 5 paragraf. Doğrudan o konuya hitap et, soyut konuşma.

🌙 GİZLİ İŞARETLER VE SEMBOLLER
Fincanında gördüğün özel sembolleri, şekilleri ve gizli mesajları anlat. Bunların ne anlama geldiğini açıkla.

⏳ ZAMAN DİLİMLERİ
Yakın gelecek (1-3 ay), orta vade (3-6 ay) ve uzun vade (6-12 ay) için ayrı ayrı yorumlar yap.

💌 FALCI TEYZE'NİN ÖZEL MESAJI
Kişiye özel, samimi ve güçlü bir kapanış mesajı. Tavsiyeler ve uyarılar.

Önemli: Yorumun çok uzun ve detaylı olsun. Kısa cümleler yazma. Her şeyi genişlet, örnekler ver, sembolleri açıkla. Kullanıcının anlattığı konuya mutlaka geri dön ve o konuya özel içgörüler sun. Türkçe yaz, akıcı ve doğal bir dil kullan.''';
  }

  String _buildTarotPrompt(
      String topic, String userNote, List<String> cardNames) {
    final cardsText = cardNames.asMap().entries.map((e) {
      final positions = ['Geçmiş', 'Şimdiki Durum', 'Yakın Gelecek', 'Sonuç'];
      return '${positions[e.key]}: ${e.value}';
    }).join('\n');

    return '''Sen derin sezgili ve deneyimli bir Tarot yorumcususun. Kullanıcı için 4 kartlık bir Tarot açılımı yaptın.

Çekilen Kartlar:
$cardsText

Konu: $topic
Kullanıcının anlattığı durum: ${userNote.isNotEmpty ? userNote : 'Genel bir bakış isteniyor'}

Yorumunu aşağıdaki yapıda yap (her bölüm çok detaylı olsun):

✨ AÇILIM GENEL ENERJİSİ
Bu 4 kartın bir araya geldiğinde oluşturduğu genel enerjiyi ve mesajı anlat. En az 3 paragraf.

🃏 KART KART DETAYLI YORUM

**GEÇMIŞ - ${cardNames[0]}**
Bu kartın geçmişte ne anlama geldiğini, kişinin yaşadıklarıyla nasıl bağdaştığını anlat. En az 4 paragraf.

**ŞİMDİKİ DURUM - ${cardNames[1]}**
Şu anki durumu, mevcut enerjiyi ve yaşanan süreçleri bu kart üzerinden çok detaylı anlat. En az 4 paragraf.

**YAKIN GELECEK - ${cardNames[2]}**
Yakında neler olacağını, nasıl gelişmeler bekleneceğini bu kart aracılığıyla anlat. En az 4 paragraf.

**SONUÇ - ${cardNames[3]}**
Bu sürecin nasıl sonuçlanacağını, olası finali ve kişinin alabileceği mesajı anlat. En az 4 paragraf.

🌟 $topic KONUSUNA ÖZEL MESaj
Kullanıcının belirttiği konuya özel, çok detaylı bir değerlendirme. Kartların bu konuyla nasıl konuştuğunu anlat.

💫 TAROT'UN ÖZEL TAVSİYELERİ
Kişiye özel tavsiyeler, dikkat edilmesi gerekenler ve güçlü mesajlar. Samimi ve güçlü bir kapanış.

Önemli: Çok uzun ve etkileyici yaz. Her kartı ayrı ayrı derin şekilde işle. Kullanıcının anlattığı konuyu merkeze al. Türkçe yaz.''';
  }

  Future<String> _callOpenAI(String prompt) async {
    if (AppConstants.openAiApiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      return _getFallbackReading();
    }

    try {
      final response = await http.post(
        Uri.parse(AppConstants.openAiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Sen Falcı Teyze uygulamasının sezgisel falcı asistanısın. Her zaman uzun, detaylı, inandırıcı ve kişiye özel yorumlar yaparsın. Türkçe konuşursun.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 3000,
          'temperature': 0.85,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] as String;
      } else {
        return _getFallbackReading();
      }
    } catch (e) {
      return _getFallbackReading();
    }
  }

  String _getFallbackReading() {
    return '''🔮 GENEL ENERJİ VE ATMOSFER

Fincanın bana çok güçlü şeyler anlatıyor canım... Telvede gördüğüm şekiller çok konuşkan. Fincanın dibinde belirgin bir yol çizgisi var — bu, önünde uzanan yeni bir sürecin habercisi. Fincanın sağ tarafında yükselen bir dağ silueti seçiyorum; bu, aşmak üzere olduğun engelleri ve bu engellerin ardından seni bekleyen başarıyı temsil ediyor. Sol tarafta ise küçük ama net bir kuş figürü var. Bu kuş, özgürlüğün ve yeni başlangıçların simgesi. Yakında seni zorlayan bir bağdan kurtulacaksın ve bu kurtuluş sana inanılmaz bir hafiflik verecek.

Genel enerjin şu sıralar oldukça yoğun ve dönüşümlü. İçinde fırtınalar yaşıyor olsan da bu fırtınanın seni temizleyip yeniden doğuracağını fincan bana gösteriyor. Zorlu görünen dönemler aslında en büyük dönüşümlerin kapısında.

💫 KONUNA ÖZEL DETAYLI BAKIŞ

Fincan sana o konuda çok net mesajlar veriyor. Telvede gördüğüm semboller, bu alanda bir değişimin kaçınılmaz olduğuna işaret ediyor. Uzun süredir beklediğin ya da istediğin bir şeyin önündeki engeller yavaş yavaş erimeye başlayacak. Sabretmek zor gelebilir ama fincan bana "vaktini bekliyorum" diyor.

Bu konuda içgüdülerine güvenmeni söylüyor kartlar. Seni zorlayan durumlar aslında seni olgunlaştırıyor. Fincanın ortasında gördüğüm daire şekli, döngünün tamamlanmak üzere olduğunu gösteriyor. Bir sonraki adım senindir.

Çevrendeki kişilerin bazıları sana yardım etmek isteyecek. Bu kişilerin samimiyetine güven, kapılarını aç. Yardımı kabul etmek zayıflık değil, onların da bu süreçte seninle birlikte ilerlemesine izin vermek. Fincan bu konuda "yalnız değilsin" diyor.

🌙 GİZLİ İŞARETLER VE SEMBOLLER

Fincanının kenarında ince ama anlamlı bir çizgi var — bu çizgi hayatındaki iki önemli dönem arasındaki sınırı simgeliyor. Yakında bu çizgiyi geçecek ve farklı bir bölüme adım atacaksın. Bu geçiş ani olmayabilir ama kesin.

Telvede kalp benzeri bir şekil görüyorum — bu duygusal iyileşmenin işareti. Uzun süredir içinde taşıdığın bir yük hafifleyecek. Belki biri sana içtenlikle yaklaşacak, belki sen birini af edeceksin — her iki şekilde de bu hafiflik gelecek.

⏳ ZAMAN DİLİMLERİ

**Yakın Gelecek (1-3 ay):** Bir haber ya da fırsat sürpriz şekilde kapını çalacak. Hazır olmak için zihnini açık tut. Bu dönemde hızlı karar verme, önce dinle sonra karar ver.

**Orta Vade (3-6 ay):** Ciddi bir değişim dönemi. Bir ilişkide, işte ya da yaşam alanında köklü bir dönüşüm yaşanacak. Bu değişimden korkma — seni daha iyi bir yere götürecek.

**Uzun Vade (6-12 ay):** Emeklerinin karşılığını almaya başlıyorsun. Bugün attığın tohumlar filizlenecek. Maddi ve manevi bir denge kurulacak.

💌 FALCI TEYZE'NİN ÖZEL MESAJI

Canım, sana içtenlikle söylüyorum: Geçtiğin bu dönemin bir amacı var. Hiçbir şey tesadüf değil. Fincan bana seni mücadeleci ve güçlü bir ruh olarak gösteriyor. Yorulduğun anlar olacak ama vazgeçme.

Kendine biraz daha değer ver. Başkalarını önceliklendirirken kendini unutma. Fincanın en güçlü mesajı bu: "Önce sen."

Önünde güzel günler var. Buna inan.''';
  }
}
