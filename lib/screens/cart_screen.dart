import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/models/product_model.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/product_details.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductProviders>(
        builder: (context, recipeProviders, child) {
          double getTotal(Map<ProductModel, int> cartProducts) {
            double total = 0.0;
            cartProducts.forEach((producto, cantidad) {
              total += producto.precio * cantidad;
            });
            return total;
          }

          final cartEntries = recipeProviders.cartProducts.entries.toList();
          final total = getTotal(recipeProviders.cartProducts);

          return cartEntries.isEmpty
              ? Center(child: Text("Ningun producto añadido al carrito"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartEntries.length,
                      itemBuilder: (context, index) {
                        final entry = cartEntries[index];
                        final recipe = entry.key;
                        final cantidad = entry.value;

                        return CartProductsCard(
                          recipe: recipe,
                          cantidad: cantidad,
                          total: total,
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Provider.of<ProductProviders>(
                                context,
                                listen: false,
                              ).emptyCart();

                              // Opcional: Mostrar un mensaje al usuario
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Productos comprados!!"),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size.fromHeight(60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Comprar ahora!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
        },
      ),
    );
  }
}

class CartProductsCard extends StatelessWidget {
  final ProductModel recipe;
  final int cantidad;
  final double total;
  const CartProductsCard({
    super.key,
    required this.recipe,
    required this.cantidad,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetails(recipesData: recipe),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Card(
          color: Colors.white,
          //child: Row(children: [Text(recipe.name), Text(recipe.author)]),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.amberAccent),
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(recipe.imageLink, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recipe.name,
                        style: TextStyle(fontSize: 18, fontFamily: 'QuikSand'),
                      ),
                      Container(
                        color: colors.primary,
                        height: 2,
                        width: size.width * 0.5,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "\$${recipe.precio}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Cant: $cantidad", style: TextStyle(fontSize: 14)),
                      Text(
                        "\$${(cantidad * recipe.precio).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
