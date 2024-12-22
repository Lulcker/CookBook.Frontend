class ProductModel {
  final String id;
  final String name;

  ProductModel({
    required this.id,
    required this.name
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name']
    );
  }
}

class CreateProductModel {
  String name;

  CreateProductModel(
      {
        required this.name
      });

  Map<String, dynamic> toJson() {
    return {
      'name': name
    };
  }
}

class UpdateProductModel {
  String id;
  String name;

  UpdateProductModel(
      {
        required this.id,
        required this.name
      });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name
    };
  }
}