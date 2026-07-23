import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
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
}