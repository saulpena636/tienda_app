class ProductModel {
  int id;
  String name;
  double precio;
  String imageLink;
  String description;

  //constructor
  ProductModel({
    required this.id,
    required this.name,
    required this.precio,
    required this.imageLink,
    required this.description,
  });

  factory ProductModel.fromJSON(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      precio: json['precio'],
      imageLink: json['imageLink'],
      description: json['description'],
    );
  }

  // conversor a JSON
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'precio': precio,
      'imageLink': imageLink,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, precio: $precio, imageLink: $imageLink, description: $description)';
  }
}
