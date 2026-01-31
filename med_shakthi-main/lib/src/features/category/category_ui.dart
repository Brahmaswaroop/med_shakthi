import 'package:flutter/material.dart';
import 'category_products_page.dart';
import 'product_filter_sheet.dart';
import 'b2b_product_filter.dart';

class CategoryPageNew extends StatelessWidget {
  const CategoryPageNew({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7), // keep current light theme
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black87),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'Shop by Category',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: const _CategoryBody(),
    );
  }
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SearchAndFilterBar(),
                  SizedBox(height: 12),
                  _ShortcutSection(),
                  SizedBox(height: 16),
                  _CategoryGroupTitle(title: 'Core Pharmacy'),
                ],
              ),
            ),
          ),

          // Core Pharmacy grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = corePharmacyCategories[index];
                return CategoryCard(item: item);
              }, childCount: corePharmacyCategories.length),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [_CategoryGroupTitle(title: 'Personal Care')],
              ),
            ),
          ),

          // Personal care grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = personalCareCategories[index];
                return CategoryCard(item: item);
              }, childCount: personalCareCategories.length),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [_CategoryGroupTitle(title: 'Devices & Tools')],
              ),
            ),
          ),

          // Devices grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = deviceCategories[index];
                return CategoryCard(item: item);
              }, childCount: deviceCategories.length),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search + filter row (like modern pharmacy UI)
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines, categories…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        /// ✅ FILTER BUTTON (FIXED)
        GestureDetector(
          onTap: () async {
            final filters = await showModalBottomSheet<B2BProductFilter>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const ProductFilterSheet(),
            );

            if (filters != null) {
              debugPrint('Applied sort: ${filters.sortBy}');
            }
          },
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xff2b9c8f),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recently ordered + Popular chips row
class _ShortcutSection extends StatelessWidget {
  const _ShortcutSection();

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      'Recently ordered',
      'Popular in your area',
      'Best margins',
    ];

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shortcuts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffe0e0e0)),
            ),
            child: Row(
              children: [
                if (index == 0)
                  const Icon(Icons.history, size: 14, color: Colors.teal),
                if (index == 1)
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.orange,
                  ),
                if (index == 2)
                  const Icon(Icons.trending_up, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  shortcuts[index],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryGroupTitle extends StatelessWidget {
  final String title;

  const _CategoryGroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}

/// DATA MODEL

class CategoryItem {
  final String title;
  final String imageAsset;
  final String skuCountText; // e.g. "120+ SKUs"
  final String badgeText; // e.g. "Fast moving" / "Offer"
  final Color badgeColor;

  CategoryItem({
    required this.title,
    required this.imageAsset,
    required this.skuCountText,
    required this.badgeText,
    required this.badgeColor,
  });
}

// Example data: map these to your real categories & images.
final List<CategoryItem> corePharmacyCategories = [
  CategoryItem(
    title: 'Medicines',
    imageAsset: 'assets/categories/medicine.png',
    skuCountText: '450+ SKUs',
    badgeText: 'Fast moving',
    badgeColor: Colors.green.shade600,
  ),
  CategoryItem(
    title: 'Diabetes',
    imageAsset: 'assets/categories/diabetes.png',
    skuCountText: '90+ SKUs',
    badgeText: 'High margin',
    badgeColor: Colors.blue.shade600,
  ),
  CategoryItem(
    title: 'BP Monitor',
    imageAsset: 'assets/categories/bp_monitor.png',
    skuCountText: '25 SKUs',
    badgeText: 'Top rated',
    badgeColor: Colors.orange.shade600,
  ),
];

final List<CategoryItem> personalCareCategories = [
  CategoryItem(
    title: 'Face & Beauty',
    imageAsset: 'assets/categories/face_care.png',
    skuCountText: '120+ SKUs',
    badgeText: 'Up to 20% off',
    badgeColor: Colors.red.shade500,
  ),
  CategoryItem(
    title: 'Hair Care',
    imageAsset: 'assets/categories/hair_care.png',
    skuCountText: '80+ SKUs',
    badgeText: 'Fast moving',
    badgeColor: Colors.green.shade600,
  ),
  CategoryItem(
    title: 'Soaps & Bodywash',
    imageAsset: 'assets/categories/soap.png',
    skuCountText: '140+ SKUs',
    badgeText: 'Best margins',
    badgeColor: Colors.blue.shade600,
  ),
];

final List<CategoryItem> deviceCategories = [
  CategoryItem(
    title: 'Thermometer',
    imageAsset: 'assets/categories/thermometer.png',
    skuCountText: '20 SKUs',
    badgeText: 'Bestseller',
    badgeColor: Colors.orange.shade600,
  ),
  CategoryItem(
    title: 'Oximeter',
    imageAsset: 'assets/categories/oximeter.png',
    skuCountText: '15 SKUs',
    badgeText: 'Only few left',
    badgeColor: Colors.red.shade500,
  ),
  CategoryItem(
    title: 'Weighing Scale',
    imageAsset: 'assets/categories/weight_scale.png',
    skuCountText: '10 SKUs',
    badgeText: 'New',
    badgeColor: Colors.purple.shade500,
  ),
  CategoryItem(
    title: 'Supplements',
    imageAsset: 'assets/categories/supplement.png',
    skuCountText: '—',
    badgeText: 'Available',
    badgeColor: Colors.green.shade600,
  ),

  CategoryItem(
    title: 'Surgical',
    imageAsset: 'assets/categories/surgical.png',
    skuCountText: '—',
    badgeText: 'Available',
    badgeColor: Colors.blue.shade600,
  ),
];

/// CATEGORY CARD WIDGET

class CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const CategoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsPage(categoryName: item.title),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(item.imageAsset, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 4.0,
              ),
              child: Column(
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.skuCountText,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badgeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: item.badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
