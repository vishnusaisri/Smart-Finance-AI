import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCkk9PXlyKAtbhKkBTh3epAW-pH9FIXj0',
    authDomain: 'smart-finance-ai-8e649.firebaseapp.com',
    databaseURL:
        'https://smart-finance-ai-8e649-default-rtdb.firebaseio.com',
    projectId: 'smart-finance-ai-8e649',
    storageBucket:
        'smart-finance-ai-8e649.firebasestorage.app',
    messagingSenderId: '630053453119',
    appId:
        '1:630053453119:web:8e5e277f2179c727c3678a',
    measurementId: 'G-6SD1P75DL8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCkk9PXlyKAtbhKkBTh3epAW-pH9FIXj0',
    appId: '1:630053453119:android:com.example.smart_finance_ai',
    messagingSenderId: '630053453119',
    projectId: 'smart-finance-ai-8e649',
    databaseURL:
        'https://smart-finance-ai-8e649-default-rtdb.firebaseio.com',
    storageBucket:
        'smart-finance-ai-8e649.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCCkk9PXlyKAtbhKkBTh3epAW-pH9FIXj0',
    appId: '1:630053453119:web:8e5e277f2179c727c3678a',
    messagingSenderId: '630053453119',
    projectId: 'smart-finance-ai-8e649',
    databaseURL:
        'https://smart-finance-ai-8e649-default-rtdb.firebaseio.com',
    storageBucket:
        'smart-finance-ai-8e649.firebasestorage.app',
  );

  static const FirebaseOptions ios = android;
  static const FirebaseOptions macos = windows;
  static const FirebaseOptions linux = windows;
}