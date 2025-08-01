import 'package:flutter/material.dart';

class HygieneProductsScreen extends StatefulWidget {
  const HygieneProductsScreen({super.key, required this.userName});
  final String userName;

  @override
  State<HygieneProductsScreen> createState() => _HygieneProductsScreenState();
}

class _HygieneProductsScreenState extends State<HygieneProductsScreen> {
  final List<Map<String, dynamic>> _products = [
    {
      'image': 'assets/images/AirwickFreshmaticAutospray.png',
      'name': 'Airwick Freshmatic Autospray',
      'price': '\$12.99',
    },
    {
      'image': 'assets/images/DettolAntibacterialSoap.png',
      'name': 'Dettol Antibacterial Soap Fresh 100g',
      'price': '\$3.50',
    },
    {
      'image': 'assets/images/DettolInstantSanitizer.png',
      'name': 'Dettol Instant Sanitizer 50ml',
      'price': '\$5.25',
    },
    {
      'image': 'assets/images/HarpicPowerPlus.png',
      'name': 'Harpic Power Plus Original',
      'price': '\$7.80',
    },
    // Placeholder for additional products
    {
      'image': 'assets/images/placeholder.png',
      'name': 'Product Name',
      'price': '\$0.00',
    },
    {
      'image': 'assets/images/placeholder.png',
      'name': 'Product Name',
      'price': '\$0.00',
    },
    {
      'image': 'assets/images/placeholder.png',
      'name': 'Product Name',
      'price': '\$0.00',
    },
    {
      'image': 'assets/images/placeholder.png',
      'name': 'Product Name',
      'price': '\$0.00',
    },
  ];

  Map<String, dynamic>? _selectedProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hygiene Products',
              style: TextStyle(
                fontFamily: 'Bricolage Grotesque',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Image.asset('assets/images/Group9.png', height: 30),
          ],
        ),
        backgroundColor: const Color(0xFF007A33),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFFFFBF0),
      body: _selectedProduct == null ? _buildProductGrid() : _buildProductDetail(),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.35,
                    letterSpacing: -0.01,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF007A33)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedProduct = product;
                    });
                  },
                  icon: Image.asset('assets/images/view.png', width: 16),
                  label: const Text(
                    'View',
                    style: TextStyle(
                      color: Color(0xFF007A33),
                      fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF007A33)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _selectedProduct!['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedProduct!['name'],
            style: const TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 1.35,
              color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedProduct!['price'],
            style: const TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF007A33)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedProduct = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            ),
            child: const Text(
              'BACK TO PRODUCTS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}