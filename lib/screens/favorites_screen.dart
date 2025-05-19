import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/models/product_model.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/product_details.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //return Center(child: Text("Favoritos"));
    return Scaffold(
      //appBar: AppBar(),
      body: Consumer<ProductProviders>(
        builder: (context, recipeProviders, child) {
          final favoriteRecipes = recipeProviders.favoriteRecipes;

          return favoriteRecipes.isEmpty
              ? Center(child: Text("Sin productos guardados"))
              : ListView.builder(
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];
                  return FavoriteRecipesCard(recipe: recipe);
                },
              );
        },
      ),
    );
  }
}

class FavoriteRecipesCard extends StatelessWidget {
  final ProductModel recipe;
  const FavoriteRecipesCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    //final size = MediaQuery.of(context).size;
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
                    style: TextStyle(fontSize: 16, fontFamily: 'QuickSand'),
                  ),
                  Container(width: 150, height: 3, color: colors.primary),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "\$${(recipe.precio * 1.2).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'QuickSand',
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "\$${recipe.precio.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'QuickSand',
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
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
