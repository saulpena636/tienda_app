import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tienda_app/models/product_model.dart';

class ProductProviders extends ChangeNotifier {
  bool isLoading = false;

  List<ProductModel> recipes = [];
  List<ProductModel> favoriteRecipes = [];
  Map<ProductModel, int> cartProducts = {};

  String getBaseUrl() {
    if (kIsWeb) {
      // Running in a web browser - assuming server is accessible from browser's perspective
      // This might need adjustment based on how you host/proxy your API for web
      return 'http://localhost:12346'; // Or your domain
    } else if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host localhost
      return 'http://10.0.2.2:12346';
    } else if (Platform.isIOS) {
      // iOS Simulator uses localhost or 127.0.0.1
      return 'http://localhost:12346';
    } else {
      // Default or other platforms (handle physical devices separately)
      // For physical devices, you'd need the host machine's actual network IP
      // e.g., 'http://192.168.1.100:12345'
      // Returning localhost as a fallback might not work universally
      return 'http://localhost:12346';
    }
  }

  Future<void> fetchRecipes() async {
    isLoading = true;
    notifyListeners();
    // Android 10.0.2.2
    // IOS 127.0.0.1
    // WEB

    final url = Uri.parse('${getBaseUrl()}/productos');

    print("Fetch Recipes");
    try {
      print("Trying");

      final response = await http.get(url);

      print("response status ${response.statusCode}");
      print("respuesta ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //return data['recipes'];
        recipes = List<ProductModel>.from(
          data['products'].map((recipe) => ProductModel.fromJSON(recipe)),
        );
      } else {
        //print('Error ${response.statusCode}');
        //return [];
        recipes = [];
      }
    } catch (e) {
      //print("Errro in request $e");
      //return [];
      recipes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatusv0(ProductModel recipe) async {
    final isFavorite = favoriteRecipes.contains(recipe);

    try {
      final url = Uri.parse('${getBaseUrl()}/favorites');
      final response =
          isFavorite
              ? await http.delete(url, body: json.encode({"id": recipe.id}))
              : await http.post(url, body: json.encode(recipe.toJSON()));

      if (response.statusCode == 200) {
        print(response.statusCode);

        if (isFavorite) {
          favoriteRecipes.remove(recipe);
        } else {
          favoriteRecipes.add(recipe);
          //print(favoriteRecipes);
        }
        print(isFavorite);
        print(favoriteRecipes.length);
        print(favoriteRecipes);

        notifyListeners();
      } else {
        throw Exception("Failure while updating favorite recipes");
      }
      notifyListeners();
    } catch (e) {
      //print("Error updating favorite recipes $e");
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(ProductModel recipe) async {
    final isFavorite = favoriteRecipes.contains(recipe);

    try {
      if (isFavorite) {
        favoriteRecipes.remove(recipe);
      } else {
        favoriteRecipes.add(recipe);
        //print(favoriteRecipes);
      }
      print(isFavorite);
      print(favoriteRecipes.length);
      print(favoriteRecipes);

      notifyListeners();
    } catch (e) {
      //print("Error updating favorite recipes $e");
      notifyListeners();
    }
  }

  Future<void> toggleCartStatus(ProductModel product, int cant) async {
    final cartAdded = cartProducts.containsKey(product);

    try {
      if (cartAdded) {
        cartProducts.remove(product);
      } else {
        cartProducts[product] = cant;
        //print(favoriteRecipes);
      }
      print(cartAdded);
      print(cartProducts.length);
      print(cartProducts);
      notifyListeners();
    } catch (e) {
      //print("Error updating favorite recipes $e");
      notifyListeners();
    }
  }

  // New function to save a recipe
  Future<bool> saveRecipe(ProductModel recipe) async {
    // Assuming your save endpoint is the same or adjust accordingly
    try {
      print('Save: recipes length: ${recipes.length}');
      recipes.add(recipe);
      print('recipes length: ${recipes.length}');

      notifyListeners();
      return true;
    } catch (e) {
      print('Error saving recipe: $e');
      return false;
    }
  }
}
