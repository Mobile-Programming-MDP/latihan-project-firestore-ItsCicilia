// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDW9W9G3TpwY6c0ORdg2BomwvoSCuYC24A',
    appId: '1:306705098708:web:85089970ca7ad831dd9841',
    messagingSenderId: '306705098708',
    projectId: 'notes-3c015',
    authDomain: 'notes-3c015.firebaseapp.com',
    storageBucket: 'notes-3c015.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxLQvColLa34TKkKsNDOJt21ab7TeAFjk',
    appId: '1:306705098708:android:cc0ca4bbe634a57edd9841',
    messagingSenderId: '306705098708',
    projectId: 'notes-3c015',
    storageBucket: 'notes-3c015.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAa3y1k3aLm6cVBjsMi6NCAoPUudNyHBsQ',
    appId: '1:306705098708:ios:7ef0ab39bed89e4bdd9841',
    messagingSenderId: '306705098708',
    projectId: 'notes-3c015',
    storageBucket: 'notes-3c015.appspot.com',
    iosBundleId: 'com.example.notes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAa3y1k3aLm6cVBjsMi6NCAoPUudNyHBsQ',
    appId: '1:306705098708:ios:7ef0ab39bed89e4bdd9841',
    messagingSenderId: '306705098708',
    projectId: 'notes-3c015',
    storageBucket: 'notes-3c015.appspot.com',
    iosBundleId: 'com.example.notes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDW9W9G3TpwY6c0ORdg2BomwvoSCuYC24A',
    appId: '1:306705098708:web:78f08ecd040759dcdd9841',
    messagingSenderId: '306705098708',
    projectId: 'notes-3c015',
    authDomain: 'notes-3c015.firebaseapp.com',
    storageBucket: 'notes-3c015.appspot.com',
  );
}
