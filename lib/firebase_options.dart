// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ??
            '', // Add your Web API key in .env file
        appId: '1:278549662505:web:9b3c537adb998684b3c538',
        messagingSenderId: '278549662505',
        projectId: 'story-king-94d54',
        authDomain: 'story-king-94d54.firebaseapp.com',
        storageBucket: 'story-king-94d54.firebasestorage.app',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ??
            '', // Add your Android API key in .env file
        appId: '1:278549662505:android:e4fceb17f83e2502b3c538',
        messagingSenderId: '278549662505',
        projectId: 'story-king-94d54',
        storageBucket: 'story-king-94d54.firebasestorage.app',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ??
            '', // Add your iOS API key in .env file
        appId: '1:278549662505:ios:2409db82417a3b8ab3c538',
        messagingSenderId: '278549662505',
        projectId: 'story-king-94d54',
        storageBucket: 'story-king-94d54.firebasestorage.app',
        iosBundleId: 'com.example.androidApp',
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ??
            '', // Add your macOS API key in .env file
        appId: '1:278549662505:ios:2409db82417a3b8ab3c538',
        messagingSenderId: '278549662505',
        projectId: 'story-king-94d54',
        storageBucket: 'story-king-94d54.firebasestorage.app',
        iosBundleId: 'com.example.androidApp',
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY'] ??
            '', // Add your Windows API key in .env file
        appId: '1:278549662505:web:b51539c48262e99bb3c538',
        messagingSenderId: '278549662505',
        projectId: 'story-king-94d54',
        authDomain: 'story-king-94d54.firebaseapp.com',
        storageBucket: 'story-king-94d54.firebasestorage.app',
      );
}
