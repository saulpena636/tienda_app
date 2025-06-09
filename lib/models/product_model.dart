class ProductModel {
  int id;
  String name;
  double precio;
  List<String> mediaUrls; // Pueden ser imágenes o videos
  String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.precio,
    required this.mediaUrls,
    required this.description,
  });

  factory ProductModel.fromJSON(Map<String, dynamic> json) {
    const baseUrl = 'http://10.242.132.136:8000/';
    return ProductModel(
      id: json['id'],
      name: json['name'],
      precio: json['precio'],
      mediaUrls: List<String>.from(
        json['media'].map((item) => baseUrl + item['url']),
      ),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'precio': precio,
      'mediaUrls': mediaUrls,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, precio: $precio, mediaUrls: $mediaUrls, description: $description)';
  }
}

class UserModel {
  String username;
  String token;

  UserModel({required this.username, required this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(username: json['username'], token: json['access_token']);
  }
}
