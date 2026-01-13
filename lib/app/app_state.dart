import 'package:flutter/material.dart';
import 'package:smart_merchandiser/models/user_profile.dart';

class AppController extends ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  bool get isProfileComplete => _profile?.isComplete ?? false;

  void updateProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppController> {
  const AppStateScope({
    super.key,
    required AppController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
      throw StateError('AppStateScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
