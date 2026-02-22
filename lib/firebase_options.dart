import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// !! ÖNEMLİ: Bu dosyayı Firebase Console'dan alınan gerçek değerlerle doldurun.
// Adımlar:
// 1. https://console.firebase.google.com adresinden yeni proje oluşturun
// 2. Android uygulaması ekleyin: com.mysticfal.falciteyze
// 3. iOS uygulaması ekleyin: com.mysticfal.falciteyze
// 4. 'flutterfire configure' komutunu çalıştırın (önerilen) veya
//    google-services.json ve GoogleService-Info.plist dosyalarını ilgili dizinlere koyun
// 5. Bu dosyadaki placeholder değerleri gerçek değerlerle değiştirin

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.mysticfal.falciteyze',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:web:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
