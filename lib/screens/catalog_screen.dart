import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_merchandiser/app/app_state.dart';
import 'package:smart_merchandiser/models/display_item.dart';
import 'package:smart_merchandiser/models/product.dart';
import 'package:smart_merchandiser/models/user_profile.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: _CatalogBody(profile: profile),
        ),
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Welcome${profile == null ? '' : ', ${profile!.storeName}'}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Browse the latest catalog items and displays.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        _DisplaysSection(),
        const SizedBox(height: 24),
        _ProductsSection(),
      ],
    );
  }
}

class _DisplaysSection extends StatelessWidget {
  const _DisplaysSection();

  List<DisplayItem> _placeholderDisplays() {
    return const [
      DisplayItem(
        id: 'placeholder-1',
        displayName: 'Front-of-Store Feature',
        description: 'Seasonal promo display (images pending).',
        images: [],
        order: 1,
        isActive: true,
      ),
      DisplayItem(
        id: 'placeholder-2',
        displayName: 'Endcap Bundle',
        description: 'High-velocity bundle display (images pending).',
        images: [],
        order: 2,
        isActive: true,
      ),
      DisplayItem(
        id: 'placeholder-3',
        displayName: 'Impulse Grab & Go',
        description: 'Checkout-ready display (images pending).',
        images: [],
        order: 3,
        isActive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Displays', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('displays')
                .where('isActive', isEqualTo: true)
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Failed to load displays.'));
              }
              final items = snapshot.data?.docs
                      .map((doc) => DisplayItem.fromDoc(doc))
                      .toList() ??
                  [];
              final displayItems =
                  items.isEmpty ? _placeholderDisplays() : items;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final imageUrl =
                      item.images.isEmpty ? '' : item.images.first;
                  return SizedBox(
                    width: 240,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: imageUrl.isEmpty
                                ? const Center(
                                    child: Icon(Icons.photo, size: 48),
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image, size: 48),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Products', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('brand')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.active) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Failed to load products.'),
              );
            }
            final items = snapshot.data?.docs
                    .map((doc) => Product.fromDoc(doc))
                    .toList() ??
                [];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No products available yet.'),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 1000
                    ? 4
                    : width >= 720
                        ? 3
                        : width >= 520
                            ? 2
                            : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return _ProductCard(product: product);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: product.imageUrl.isEmpty
                ? const Center(child: Icon(Icons.photo, size: 48))
                : Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'UPC: ${product.upc}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (product.itemSize.isNotEmpty)
                      _Chip(text: product.itemSize),
                    if (product.strPack.toString().isNotEmpty)
                      _Chip(text: 'Pack ${product.strPack}'),
                    if (product.srp.toString().isNotEmpty)
                      _Chip(text: 'SRP ${product.srp}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
