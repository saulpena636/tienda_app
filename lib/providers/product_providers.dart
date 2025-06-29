import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tienda_app/models/product_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String getBaseUrl() {
    if (kIsWeb) {
      // Running in a web browser - assuming server is accessible from browser's perspective
      // This might need adjustment based on how you host/proxy your API for web
      return 'http://localhost:8000'; // Or your domain
    } else if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host localhost
      return 'http://10.10.7.40:8000';
    } else if (Platform.isIOS) {
      // iOS Simulator uses localhost or 127.0.0.1
      return 'http://localhost:8000';
    } else {
      // Default or other platforms (handle physical devices separately)
      // For physical devices, you'd need the host machine's actual network IP
      // e.g., 'http://192.168.1.100:12345'
      // Returning localhost as a fallback might not work universally
      return 'http://localhost:8000';
    }
  }

  UserModel? user;

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    final url = Uri.parse(
      'http://10.10.7.40:8000/auth/login',
    ); // Cambia esto en producción
    final response = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      _username = username;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    _token = null;
    _username = null;
    notifyListeners();
  }
}

class ProductProviders extends ChangeNotifier {
  bool isLoading = false;

  List<ProductModel> recipes = [];
  List<ProductModel> favoriteRecipes = [];
  Map<ProductModel, int> cartProducts = {};

  String getBaseUrl() {
    if (kIsWeb) {
      // Running in a web browser - assuming server is accessible from browser's perspective
      // This might need adjustment based on how you host/proxy your API for web
      return 'http://localhost:8000'; // Or your domain
    } else if (Platform.isAndroid) {
      // Android Emulator uses 10.0.2.2 to access host localhost
      return 'http://10.10.7.40:8000';
    } else if (Platform.isIOS) {
      // iOS Simulator uses localhost or 127.0.0.1
      return 'http://localhost:8000';
    } else {
      // Default or other platforms (handle physical devices separately)
      // For physical devices, you'd need the host machine's actual network IP
      // e.g., 'http://192.168.1.100:12345'
      // Returning localhost as a fallback might not work universally
      return 'http://localhost:8000';
    }
  }

  Future<void> fetchRecipes() async {
    // NO LLAMES notifyListeners() aquí aún

    try {
      isLoading = true;

      final url = Uri.parse('${getBaseUrl()}/products');
      print("Fetch Products");

      final response = await http.get(url);
      print("response status ${response.statusCode}");
      print("respuesta ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        recipes = List<ProductModel>.from(
          data.map((product) => ProductModel.fromJSON(product)),
        );
      } else {
        print('Error ${response}');
        recipes = [];
      }
    } catch (e) {
      print("Error in request $e");
      recipes = [];
    } finally {
      isLoading = false;
      notifyListeners(); // ✅ Solo aquí, después de que todo terminó
    }
  }

  Future<void> fetchFavorites() async {
    try {
      final url = Uri.parse('${getBaseUrl()}/favorites');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ids = List<int>.from(data.map((fav) => fav['product_id']));

        // Usar la lista de productos ya cargada
        favoriteRecipes =
            recipes.where((product) => ids.contains(product.id)).toList();
      }
    } catch (e) {
      print("❌ Error al cargar favoritos: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    try {
      final url = Uri.parse('${getBaseUrl()}/cart/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cartMap = <ProductModel, int>{};

        for (var item in data) {
          final product = recipes.firstWhere((p) => p.id == item['product_id']);
          cartMap[product] = item['quantity'];
        }

        cartProducts = cartMap;
      }
    } catch (e) {
      print("❌ Error al cargar el carrito: $e");
    } finally {
      notifyListeners();
    }
  }

  /*Future<void> toggleFavoriteStatus(ProductModel product) async {
    final isFavorite = favoriteRecipes.contains(product);

    try {
      if (isFavorite) {
        favoriteRecipes.remove(product);
      } else {
        favoriteRecipes.add(product);
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
  }*/

  Future<void> toggleFavoriteStatus(ProductModel product) async {
    final isFavorite = favoriteRecipes.contains(product);
    final url =
        isFavorite
            ? Uri.parse('${getBaseUrl()}/favorites/${product.id}')
            : Uri.parse('${getBaseUrl()}/favorites/');

    try {
      if (isFavorite) {
        final response = await http.delete(url);
        if (response.statusCode == 200) {
          favoriteRecipes.remove(product);
        }
      } else {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"product_id": product.id}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          favoriteRecipes.add(product);
        }
      }
      notifyListeners();
    } catch (e) {
      print("❌ Error al actualizar favoritos: $e");
      notifyListeners();
    }
  }

  Future<void> toggleCartStatus(ProductModel product, int cant) async {
    final cartAdded = cartProducts.containsKey(product);
    try {
      if (cartAdded) {
        final url = Uri.parse('${getBaseUrl()}/cart/${product.id}');
        final response = await http.delete(url);
        if (response.statusCode == 200) {
          cartProducts.remove(product);
        }
      } else {
        final url = Uri.parse('${getBaseUrl()}/cart/');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"product_id": product.id, "quantity": cant}),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          cartProducts[product] = cant;
        }
      }
      notifyListeners();
    } catch (e) {
      print("❌ Error al actualizar el carrito: $e");
      notifyListeners();
    }
  }

  Future<void> emptyCart() async {
    try {
      final url = Uri.parse('${getBaseUrl()}/cart/');
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        cartProducts.clear();
      }
      notifyListeners();
    } catch (e) {
      print("❌ Error al vaciar el carrito: $e");
      notifyListeners();
    }
  }

  // New function to save a recipe
  Future<bool> saveProduct(ProductModel recipe) async {
    try {
      final url = Uri.parse('${getBaseUrl()}/products/');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(recipe.toJSON()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newProduct = ProductModel.fromJSON(data);
        recipes.add(newProduct);
        notifyListeners();
        return true;
      } else {
        print("❌ Error al guardar el producto: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('❌ Error al guardar producto: $e');
      return false;
    }
  }

  // Ejemplo para seleccionar imágenes y videos
  Future<List<File>> pickMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    } else {
      return [];
    }
  }

  Future<void> uploadProductWithMedia({
    required String name,
    required double precio,
    required String description,
    required List<File> mediaFiles,
  }) async {
    Dio dio = Dio();
    final formData = FormData.fromMap({
      'name': name,
      'precio': precio,
      'description': description,
      'media_files': [
        for (var file in mediaFiles)
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
      ],
    });

    final response = await dio.post(
      'http://10.10.7.40:8000/products',
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );

    if (response.statusCode == 200) {
      print("Producto subido correctamente");
    } else {
      print("Error al subir el producto");
    }
  }
}
