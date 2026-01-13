import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_merchandiser/app/app_state.dart';
import 'package:smart_merchandiser/firebase_options.dart';
import 'package:smart_merchandiser/screens/catalog_screen.dart';
import 'package:smart_merchandiser/screens/profile_form_screen.dart';
import 'package:smart_merchandiser/screens/setup_required_screen.dart';
import 'package:smart_merchandiser/screens/sign_in_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final AppController _controller;
  late final Future<FirebaseApp?> _firebaseInit;
  late final FirebaseOptions? _options;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _options = _resolveFirebaseOptions();
    _firebaseInit = _initFirebase();
  }

  Future<FirebaseApp?> _initFirebase() async {
    if (_options == null) {
      return null;
    }
    return Firebase.initializeApp(
      options: _options!,
    );
  }

  FirebaseOptions? _resolveFirebaseOptions() {
    try {
      return DefaultFirebaseOptions.currentPlatform;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Smart Merchandiser',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF136F63)),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: Colors.black12),
            ),
          ),
        ),
        home: AppRoot(
          firebaseInit: _firebaseInit,
          isConfigured: _options != null,
        ),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    required this.firebaseInit,
    required this.isConfigured,
  });

  final Future<FirebaseApp?> firebaseInit;
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) {
      return const SetupRequiredScreen();
    }
    return FutureBuilder<FirebaseApp?>(
      future: firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Firebase failed to initialize: ${snapshot.error}',
              ),
            ),
          );
        }
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            final user = authSnapshot.data;
            if (user == null) {
              return const SignInScreen();
            }
            final state = AppStateScope.of(context);
            if (!state.isProfileComplete) {
              return ProfileFormScreen(user: user);
            }
            return const CatalogScreen();
          },
        );
      },
    );
  }
}
