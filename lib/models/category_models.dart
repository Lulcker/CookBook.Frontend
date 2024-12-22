class CategoryModel {
  String id;
  String name;
  String description;

  CategoryModel(
    {
      required this.id,
      required this.name,
      required this.description
    });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class CreateCategoryModel {
  String name;
  String description;

  CreateCategoryModel(
    {
      required this.name,
      required this.description
    });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description
    };
  }
}

class UpdateCategoryModel {
  String id;
  String name;
  String description;

  UpdateCategoryModel(
      {
        required this.id,
        required this.name,
        required this.description
      });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description
    };
  }
}