import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/favorites_screen.dart';
import 'package:tienda_app/screens/cart_screen.dart';
import 'package:tienda_app/screens/home_screen.dart';
import 'package:tienda_app/screens/login_screen.dart'; // Asegúrate de tener este archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProviders()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Tienda',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(0, 77, 160, 255),
              ),
              useMaterial3: true,
            ),
            home:
                authProvider.isAuthenticated
                    ? const Tienda()
                    : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Sears_Logo_1994.svg/330px-Sears_Logo_1994.svg.png',
                height: 40,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 2),
              const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Inicio'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
              Tab(icon: Icon(Icons.favorite), text: 'Guardados'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [HomeScreen(), CartScreen(), FavoritesScreen()],
        ),
      ),
    );
  }
}
