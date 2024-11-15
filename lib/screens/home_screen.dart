import 'package:flutter/material.dart';
import 'package:gamestech/models/category_chip.dart';
import 'package:gamestech/models/product_card.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

int _selectedIndex = 0;

final List<String> _screens = ["Store", "Search", "Cart", "Favorites"];

class _HomeScreenState extends State<HomeScreen> {
  // Método para cerrar sesión
  void _signOut(BuildContext context) {
    // Aquí puedes agregar el código de cierre de sesión
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  const Text(
                    'Nuestros productos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => _signOut(context),
                    child: const Icon(Icons.exit_to_app,
                        size: 28, color: Colors.blue),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nuestos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar Productos',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryChip(
                            icon: Icons.phone_iphone,
                            label: 'iPhones',
                            isSelected: true,
                          ),
                          CategoryChip(
                            icon: Icons.watch,
                            label: 'Smartwatch',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          ProductCard(
                            image:
                                'https://elektra.vtexassets.com/arquivos/ids/4203373-800-auto?v=638593503263330000&width=800&height=auto&aspect=true',
                            name: 'iPhone 13',
                            price: 999.00,
                            label: 'Trending Now',
                          ),
                          ProductCard(
                            image:
                                'https://i5.walmartimages.com/asr/dd071839-1958-41e4-b734-5b801185d0e8.b5f2035787c0efded7f90d9c640f5015.jpeg?odnHeight=612&odnWidth=612&odnBg=FFFFFF',
                            name: 'Apple Watch',
                            price: 399.00,
                            label: 'Best Selling',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          // Store
          SalomonBottomBarItem(
            icon: Icon(Icons.store),
            title: Text("Store"),
            selectedColor: Colors.blue,
          ),
          // Search
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.blue,
          ),
          // Cart
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("Cart"),
            selectedColor: Colors.blue,
          ),
          // Favorites
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Favorites"),
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
