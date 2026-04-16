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
    apiKey: 'AIzaSyDIEAvo-hLBEepqZvZ2hUeUMAKDrwdsKaY',
    appId: '1:691072704853:android:624820a143e1d57b4acfdc',
    messagingSenderId: '691072704853',
    projectId: 'falci-teeyze',
    storageBucket: 'falci-teeyze.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6eJFyyPZT7FPJMoleb6wyLV43cVgt8zI',
    appId: '1:691072704853:ios:242e3a7ca0912f024acfdc',
    messagingSenderId: '691072704853',
    projectId: 'falci-teeyze',
    storageBucket: 'falci-teeyze.firebasestorage.app',
    iosBundleId: 'com.mysticfal.falciTeyze',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:web:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}