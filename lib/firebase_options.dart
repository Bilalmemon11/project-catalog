import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjiL9N8UkvIC63XzHCjeLF5LtDQA8Ers0',
    appId: '1:900214896294:web:b33debc3c0129b48266667',
    messagingSenderId: '900214896294',
    projectId: 'smart-merchandiser-b0602',
    authDomain: 'smart-merchandiser-b0602.firebaseapp.com',
    storageBucket: 'smart-merchandiser-b0602.firebasestorage.app',
    measurementId: 'G-4238KMVJDL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeBo0aL1Y7q8-KYTwvnzwW9pyGoHyvsr4',
    appId: '1:900214896294:android:b06b902b4f406492266667',
    messagingSenderId: '900214896294',
    projectId: 'smart-merchandiser-b0602',
    storageBucket: 'smart-merchandiser-b0602.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdhqEe3SCeBYfStFscrAGdhfvPc2ErC10',
    appId: '1:900214896294:ios:062e4e86f5a4b16f266667',
    messagingSenderId: '900214896294',
    projectId: 'smart-merchandiser-b0602',
    storageBucket: 'smart-merchandiser-b0602.firebasestorage.app',
    iosBundleId: 'com.example.smartMerchandiser',
  );
}
