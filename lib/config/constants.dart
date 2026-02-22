class AppConstants {
  static const String appName = 'Falcı Teyze';
  static const String packageName = 'com.mysticfal.falciteyze';
  static const String supportEmail = 'meryemka3555@gmail.com';

  // OpenAI API - Kendi API anahtarınızı buraya girin
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiBaseUrl = 'https://api.openai.com/v1/chat/completions';

  // In-App Purchase Product IDs
  static const String productSingleFortune = 'single_fortune_25tl';
  static const String productWeeklyPremium = 'weekly_premium_200tl';
  static const String productMonthlyPremium = 'monthly_premium_200tl';

  // Firestore Collections
  static const String usersCollection = 'users';
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
