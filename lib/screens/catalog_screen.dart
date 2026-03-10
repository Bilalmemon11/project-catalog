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
              final items =
                  snapshot.data?.docs
                      .map((doc) => DisplayItem.fromDoc(doc))
                      .toList() ??
                  [];
              final displayItems = items.isEmpty
                  ? _placeholderDisplays()
                  : items;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final imageUrl = item.images.isEmpty ? '' : item.images.first;
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

class _ProductsSection extends StatefulWidget {
  @override
  State<_ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<_ProductsSection> {
  static const int _pageSize = 10;
  final List<Product> _products = [];

  // Maps page number to the cursor used to start that page query.
  // Page 1 starts from the beginning, so its cursor is null.
  final Map<int, DocumentSnapshot<Map<String, dynamic>>?> _pageCursors = {
    1: null,
  };

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNextPage = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading || page < 1) return;
    if (!_pageCursors.containsKey(page)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('brand')
          .limit(_pageSize);

      final cursor = _pageCursors[page];
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final fetchedProducts = docs.map((doc) => Product.fromDoc(doc)).toList();
      final hasNext = docs.length == _pageSize;

      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(fetchedProducts);
        _currentPage = page;
        _hasNextPage = hasNext;

        if (hasNext && docs.isNotEmpty) {
          _pageCursors[page + 1] = docs.last;
        } else {
          _pageCursors.remove(page + 1);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Products', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_isLoading && _products.isEmpty && _errorMessage == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No products available yet.'),
          ),
        if (_errorMessage != null && _products.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_errorMessage!),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _loadPage(_currentPage),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        if (_products.isNotEmpty)
          LayoutBuilder(
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
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductCard(product: product);
                },
              );
            },
          ),
        if (_products.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Page $_currentPage  •  ${_products.length} products shown',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(
                onPressed: _currentPage > 1 && !_isLoading
                    ? () => _loadPage(_currentPage - 1)
                    : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _hasNextPage && !_isLoading
                    ? () => _loadPage(_currentPage + 1)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
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
    final imageUrls = product.imageUrls;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: _ProductImageGallery(
              productName: product.description,
              imageUrls: imageUrls,
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
                Text('UPC: ${product.upc}', style: theme.textTheme.bodySmall),
                if (product.imageKey.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Image key: ${product.imageKey}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
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

class _ProductImageGallery extends StatefulWidget {
  const _ProductImageGallery({
    required this.productName,
    required this.imageUrls,
  });

  final String productName;
  final List<String> imageUrls;

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openGallery(BuildContext context) {
    if (widget.imageUrls.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenGallery(
          title: widget.productName,
          imageUrls: widget.imageUrls,
          initialIndex: _currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const _ImageFrame(
        child: Icon(Icons.photo, size: 48),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openGallery(context),
              child: _NetworkProductImage(
                imageUrl: widget.imageUrls[index],
                semanticsLabel: '${widget.productName} image ${index + 1}',
              ),
            );
          },
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            right: 10,
            top: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        if (widget.imageUrls.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.black87 : Colors.black26,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _NetworkProductImage extends StatelessWidget {
  const _NetworkProductImage({
    required this.imageUrl,
    required this.semanticsLabel,
  });

  final String imageUrl;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return _ImageFrame(
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        alignment: Alignment.center,
        semanticLabel: semanticsLabel,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }
}

class _ImageFrame extends StatelessWidget {
  const _ImageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F4F2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({
    required this.title,
    required this.imageUrls,
    required this.initialIndex,
  });

  final String title;
  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return ColoredBox(
                  color: Colors.black,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 56,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              },
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
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
