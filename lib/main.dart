import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/favorites_screen.dart';
import 'package:tienda_app/screens/cart_screen.dart';
import 'package:tienda_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProductProviders())],
      child: MaterialApp(
        title: 'Tienda',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ), // Azul como base
          useMaterial3: true, // O false si estás usando Material 2
        ),
        home: Tienda(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Tienda extends StatelessWidget {
  const Tienda({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: Text(
            "Tienda de compras",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home), text: 'Inicio'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
              Tab(icon: Icon(Icons.favorite), text: 'Guardados'),
            ],
          ),
        ),
        body: //HomeScreen(),
            TabBarView(
          children: [HomeScreen(), CartScreen(), FavoritesScreen()],
        ),
      ),
    );
  }
}
