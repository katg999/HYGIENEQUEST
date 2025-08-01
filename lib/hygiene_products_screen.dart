import 'package:flutter/material.dart';
import 'lesson_plans_screen.dart';
import 'attendance_screen.dart';

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
      'piecePrice': 'UGX34,225',
      'cartonPrice': 'UGX256,900',
    },
    {
      'image': 'assets/images/DettolAntibacterialSoap.png',
      'name': 'Dettol Antibacterial Soap Fresh 100g',
      'piecePrice': 'UGX2,779',
      'cartonPrice': 'UGX495,210',
    },
    {
      'image': 'assets/images/DettolInstantSanitizer.png',
      'name': 'Dettol Instant Sanitizer 50ml',
      'piecePrice': 'UGX2,547',
      'cartonPrice': 'UGX364,514',
    },
    {
      'image': 'assets/images/HarpicPowerPlus.png',
      'name': 'Harpic Power Plus Original',
      'piecePrice': 'UGX8,268',
      'cartonPrice': 'UGX318,443',
    },
    // Placeholder for additional products - commented out for now
    // {
    //   'image': 'assets/images/placeholder.png',
    //   'name': 'Product Name',
    //   'piecePrice': 'UGX0.00',
    //   'cartonPrice': 'UGX0.00',
    // },
    // {
    //   'image': 'assets/images/placeholder.png',
    //   'name': 'Product Name',
    //   'piecePrice': 'UGX0.00',
    //   'cartonPrice': 'UGX0.00',
    // },
    // {
    //   'image': 'assets/images/placeholder.png',
    //   'name': 'Product Name',
    //   'piecePrice': 'UGX0.00',
    //   'cartonPrice': 'UGX0.00',
    // },
    // {
    //   'image': 'assets/images/placeholder.png',
    //   'name': 'Product Name',
    //   'piecePrice': 'UGX0.00',
    //   'cartonPrice': 'UGX0.00',
    // },
  ];

  Map<String, dynamic>? _selectedProduct;
  int _currentIndex = 2; // Set to 2 since this is the Hygiene tab

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
      body: Column(
        children: [
          Expanded(
            child: _selectedProduct == null ? _buildProductGrid() : _buildProductDetail(),
          ),
          _buildBottomNavBar(),
        ],
      ),
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
          childAspectRatio: 0.7,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Per piece: ',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          product['piecePrice'],
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF007A33),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'Carton: ',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          product['cartonPrice'],
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF007A33),
                          ),
                        ),
                      ],
                    ),
                  ],
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

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: 'assets/images/Lessonplan.png',
            label: 'Lesson Plans',
            isSelected: _currentIndex == 0,
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonPlansScreen(userName: widget.userName),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: 'assets/images/Attendance.png',
            label: 'Attendance',
            isSelected: _currentIndex == 1,
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(userName: widget.userName),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: 'assets/images/HygieneProducts.png',
            label: 'Hygiene',
            isSelected: _currentIndex == 2,
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A33) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 24,
              color: isSelected ? Colors.white : const Color(0xFF007A33),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF007A33),
                fontSize: 12,
              ),
            ),
          ],
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Per piece price:',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      _selectedProduct!['piecePrice'],
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF007A33),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Carton price:',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      _selectedProduct!['cartonPrice'],
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF007A33),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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