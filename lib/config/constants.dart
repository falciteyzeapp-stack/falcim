class AppConstants {
  static const String appName = 'Falcim';
  static const String packageName = 'com.mysticfal.falciteyze';
  static const String supportEmail = 'meryemka3555@gmail.com';

  // OpenAI API - Kendi API anahtarınızı buraya girin
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';

  // In-App Purchase Product IDs — sadece consumable 25 TL
  static const String productSingleFortune = 'fal_hakki_1';

  // Firestore Collections
  static const String usersCollection = 'kullanicilar';
  static const String readingsCollection = 'readings';
  static const String phonesCollection = 'phones';

  // Waiting duration
  static const int waitingMinutes = 5;

  // Fortune topics
  static const List<String> fortuneTopics = [
    'Genel',
    'Aşk & İlişkiler',
    'İş & Kariyer',
    'Sağlık',
    'Aile',
    'Para & Finans',
  ];
}
