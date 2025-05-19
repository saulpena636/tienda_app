import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/models/product_model.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/product_details.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //return Center(child: Text("Favoritos"));
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(),
      body: Consumer<ProductProviders>(
        builder: (context, recipeProviders, child) {
          final cartEntries = recipeProviders.cartProducts.entries.toList();

          return cartEntries.isEmpty
              ? Center(child: Text("Sin productos guardados"))
              : ListView.builder(
                itemCount: cartEntries.length,
                itemBuilder: (context, index) {
                  final entry = cartEntries[index];
                  final recipe = entry.key;
                  final cantidad = entry.value;

                  return CartProductsCard(recipe: recipe, cantidad: cantidad);
                },
              );
        },
      ),
    );
  }
}

class CartProductsCard extends StatelessWidget {
  final ProductModel recipe;
  const CartProductsCard({
    super.key,
    required this.recipe,
    required int cantidad,
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
                  Text("\$${recipe.precio}", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
