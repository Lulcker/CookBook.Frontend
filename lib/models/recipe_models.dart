class RecipeModel {
  String id;
  String name;
  String ingredients;
  String photoLink;
  double rating;
  DateTime createdDateTime;
  bool isAddedToFavorite;

  RecipeModel(
    {
      required this.id,
      required this.name,
      required this.ingredients,
      required this.photoLink,
      required this.rating,
      required this.createdDateTime,
      required this.isAddedToFavorite
    });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      name: json['name'],
      ingredients: json['ingredients'],
      photoLink: json['photoLink'],
      rating: json['rating'].toDouble(),
      createdDateTime: DateTime.parse(json['createdDateTime']),
      isAddedToFavorite: bool.parse(json['isAddedToFavorite'].toString()),
    );
  }
}

class FavoriteRecipeModel {
  String id;
  String recipeId;
  String name;
  String ingredients;
  String photoLink;
  DateTime addedDateTime;

  FavoriteRecipeModel(
    {
      required this.id,
      required this.recipeId,
      required this.name,
      required this.ingredients,
      required this.photoLink,
      required this.addedDateTime
    });

  factory FavoriteRecipeModel.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipeModel(
      id: json['id'],
      recipeId: json['recipeId'],
      name: json['name'],
      ingredients: json['ingredients'],
      photoLink: json['photoLink'],
      addedDateTime: DateTime.parse(json['addedDateTime']),
    );
  }
}

class RecipeFullInfoModel {
  String id;
  String name;
  String description;
  DateTime createdDateTime;
  String photoLink;
  double rating;
  String categoryName;
  String userLogin;
  bool isAddedToFavorite;
  List<IngredientModel> ingredients;
  List<RecipeStepModel> recipeSteps;

  RecipeFullInfoModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDateTime,
    required this.photoLink,
    required this.rating,
    required this.categoryName,
    required this.userLogin,
    required this.isAddedToFavorite,
    required this.ingredients,
    required this.recipeSteps
  });

  factory RecipeFullInfoModel.fromJson(Map<String, dynamic> json) {
    return RecipeFullInfoModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdDateTime: DateTime.parse(json['createdDateTime']),
      photoLink: json['photoLink'],
      rating: json['rating'].toDouble(),
      categoryName: json['categoryName'],
      userLogin: json['userLogin'],
      isAddedToFavorite: json['isAddedToFavorite'],
      ingredients: List<IngredientModel>.from(
        json['ingredients'].map((ingredient) => IngredientModel.fromJson(ingredient)),
      ),
      recipeSteps: List<RecipeStepModel>.from(
        json['recipeSteps'].map((step) => RecipeStepModel.fromJson(step)),
      ),
    );
  }
}

class IngredientModel {
  String id;
  String productName;
  double quantity;
  int unitOfMeasure;

  IngredientModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitOfMeasure
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'],
      productName: json['productName'],
      quantity: json['quantity'].toDouble(),
      unitOfMeasure: json['unitOfMeasure'],
    );
  }
}

class RecipeStepModel{
  String id;
  String description;
  String? photoLink;

  RecipeStepModel({
    required this.id,
    required this.description,
    required this.photoLink
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      id: json['id'],
      description: json['description'],
      photoLink: json['photoLink'],
    );
  }
}

class CreateRecipeModel {
  String name;
  String description;
  String photoLink;
  String categoryId;
  List<CreateRecipeStepModel> recipeSteps;
  List<CreateRecipeIngredientModel> ingredients;

  CreateRecipeModel({
    required this.name,
    required this.description,
    required this.photoLink,
    required this.categoryId,
    required this.recipeSteps,
    required this.ingredients
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'photoLink': photoLink,
      'categoryId': categoryId,
      'recipeSteps': recipeSteps.map((step) => step.toJson()).toList(),
      'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
    };
  }
}

class CreateRecipeStepModel {
  String description;
  String photoLink;
  int index;

  CreateRecipeStepModel({
    required this.description,
    required this.photoLink,
    required this.index
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'photoLink': photoLink
    };
  }
}

class CreateRecipeIngredientModel {
  double quantity;
  UnitOfMeasure unitOfMeasure;
  String productId;

  CreateRecipeIngredientModel({
    required this.quantity,
    required this.unitOfMeasure,
    required this.productId
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure.index,
      'productId': productId
    };
  }
}

class ApproveRecipeModel {
  String id;
  String name;
  String description;

  ApproveRecipeModel({
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

class RejectRecipeModel {
  String id;
  String comment;

  RejectRecipeModel({
    required this.id,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment
    };
  }
}

enum UnitOfMeasure {
  piece,

  gram,

  kilogram,

  liter,

  tablespoon,

  teaspoon,

  pinch
}

class EnumHelper{
  static List<Map<UnitOfMeasure, String>> unitOfMeasures = [
    createMap(UnitOfMeasure.piece, 'шт.'),
    createMap(UnitOfMeasure.gram, 'г.'),
    createMap(UnitOfMeasure.kilogram, 'кг.'),
    createMap(UnitOfMeasure.liter, 'л.'),
    createMap(UnitOfMeasure.tablespoon, 'ст. ложка'),
    createMap(UnitOfMeasure.teaspoon, 'ч. ложка'),
    createMap(UnitOfMeasure.pinch, 'щепотка'),
  ];

  static Map<UnitOfMeasure, String> createMap(UnitOfMeasure unit, String value) {
    return {unit: value};
  }

  static String? getMeasure(int index) {
    for (var map in unitOfMeasures) {
      var key = map.keys.first;
      if (key.index == index) {
        return map[key];
      }
    }
    return null;
  }
}