import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_merchandiser/app/app_state.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppStateScope.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Merchandiser'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              AppStateScope.of(context).clearProfile();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Catalog access granted',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome${profile == null ? '' : ', ${profile.storeName}'}!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Milestone 1 complete. Catalog content and product images '
                    'will be wired up in Milestone 2 after storage and '
                    'Firestore setup are resolved.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _UpcomingSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Next up in Milestone 2',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Firestore data connection'),
            Text('• Product catalog grid and filters'),
            Text('• Image storage integration'),
            Text('• Displays section assets'),
          ],
        ),
      ),
    );
  }
}
