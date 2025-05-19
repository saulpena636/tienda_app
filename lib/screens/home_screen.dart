import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_app/providers/product_providers.dart';
import 'package:tienda_app/screens/product_details.dart';

import '../models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipesProvider = Provider.of<ProductProviders>(
      context,
      listen: false,
    );

    if (recipesProvider.recipes.isEmpty) {
      recipesProvider.fetchRecipes();
      print("Se cargaron las recetas");
    }

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      //body: FutureBuilder<List<dynamic>>(
      //future: fetchRecipes(),
      body: Consumer<ProductProviders>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.recipes.isEmpty) {
            return Center(child: Text('No hay recetas'));
          }

          return ListView.builder(
            itemCount: provider.recipes.length,
            itemBuilder: (context, index) {
              return _recipesCard(context, provider.recipes[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showButton(context);
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showButton(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder:
          (_) => Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            height: 500,
            child: FormularioReceta(),
          ),
    );
  }

  Widget _recipesCard(BuildContext context, dynamic recipe) {
    final colors = Theme.of(context).colorScheme;
    //print(recipe);
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
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 125,
          child: Card(
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(recipe.imageLink, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 20, height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
      ),
    );
  }
}

class FormularioReceta extends StatefulWidget {
  const FormularioReceta({super.key});

  @override
  State<FormularioReceta> createState() => _FormularioRecetaState();
}

class _FormularioRecetaState extends State<FormularioReceta> {
  final formKey = GlobalKey<FormState>();

  //controlador
  final TextEditingController _recipeName = TextEditingController();
  final TextEditingController _recipePrecio = TextEditingController();
  final TextEditingController _recipeURL = TextEditingController();
  final TextEditingController _recipeDescription = TextEditingController();

  @override
  void dispose() {
    _recipeName.dispose();
    _recipePrecio.dispose();
    _recipeURL.dispose();
    _recipeDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final formKey = GlobalKey<FormState>();
    final colors = Theme.of(context).colorScheme;
    final recipesProvider = Provider.of<ProductProviders>(
      context,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Agregar producto",
              style: TextStyle(color: colors.primary, fontSize: 20),
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeName,
              context: context,
              label: "Nombre del producto",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce el nombre del producto';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipePrecio,
              context: context,
              label: "Precio del producto",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce el precio del producto';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeURL,
              context: context,
              label: "URL de la imagen",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce la URL de la imagen';
                }
                // // Basic URL validation (optional, can be more complex)
                // if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
                //     return 'Introduce una URL válida';
                // }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeDescription,
              context: context,
              label: "Descripción",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce la descripción';
                }
                return null;
              },
              maxLines: 4,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final newRecipe = ProductModel(
                      id: recipesProvider.recipes.length + 3,
                      name: _recipeName.text,
                      precio: double.parse(_recipePrecio.text),
                      imageLink: _recipeURL.text,
                      description: _recipeDescription.text,
                      // Assuming the description is the only step for now
                    );

                    print(" nuevo producto: ${newRecipe.toString()}");

                    bool success = false;
                    //final localContext = context; // Captura el contexto actual

                    try {
                      // Call the saveRecipe function from the provider
                      success = await recipesProvider.saveRecipe(newRecipe);
                    } catch (e) {
                      return; // Exit if there was an error during save
                    }

                    print(success);

                    if (success) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Agregar producto",
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
    );
  }

  Widget _buildTextField({
    required String? Function(String?) validator,
    required TextEditingController controller,
    required BuildContext context,
    required String label,
    int maxLines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'QuickSand', color: colors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.tertiary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }
}
