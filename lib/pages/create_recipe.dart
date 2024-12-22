import 'dart:async';
import 'dart:convert';
import '../pages/recipes.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import '../models/recipe_models.dart';
import '../helpers/dialog_helper.dart';
import '../models/product_models.dart';
import 'package:flutter/material.dart';
import '../models/category_models.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CreateRecipePage extends StatefulWidget {

  @override
  _CreateRecipePageState createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  CategoryModel? _category;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoLinkController = TextEditingController();
  List<RecipeStepWidget> steps = [RecipeStepWidget(index: 0)];
  List<RecipeIngredientWidget> ingredients = [RecipeIngredientWidget()];

  bool isEnableSaveButton() {
    return _nameController.text.trim() != '' && _descriptionController.text.trim() != '' && _photoLinkController.text.trim() != '';
  }

  void _addStep() {
    setState(() {
      steps.add(RecipeStepWidget(index: steps.length + 1));
    });
  }

  void _addIngredient() {
    setState(() {
      ingredients.add(RecipeIngredientWidget());
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<CategoryModel>> _fetchCategories(String text) async {
    List<CategoryModel> parseCategories(List<dynamic> data) {
      return data.map((json) {
        return CategoryModel.fromJson(json);
      }).toList();
    }

    List<CategoryModel> newCategories = [];

    var body = await HttpHelper.get('/api/category/all', {
      'Page': '0',
      'Search': text
    });

    List<dynamic> jsonData = json.decode(body);
    newCategories = parseCategories(jsonData);

    return newCategories;
  }

  Future<void> _fetchCreateRecipe() async {
    steps.sort((d, e) => d.index.compareTo(e.index));
    final recipeSteps = steps.map((widget) {
      return CreateRecipeStepModel(description: widget._descriptionController.text, photoLink: widget._photoLinkController.text, index: widget.index);
    }).toList();

    final ingredientSteps = ingredients.map((widget) {
      return CreateRecipeIngredientModel(productId: widget._productModel!.id, quantity: double.parse(widget._quantityController.text), unitOfMeasure: widget._unitOfMeasure!.keys.first);
    }).toList();

    var createRecipeModel = CreateRecipeModel(
        name: _nameController.text,
        description: _descriptionController.text,
        photoLink: _photoLinkController.text,
        categoryId: _category!.id,
        recipeSteps: recipeSteps,
        ingredients: ingredientSteps
    ).toJson();

    await HttpHelper.post('/api/recipe/create', createRecipeModel, context);

    if (await DialogHelper.showSuccess('Рецепт успешно создан и отправлен на модерацию', context)) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => RecipesPage(categoryId: null)
          ),
              (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CookBook'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleHelper.edgeInsetsAll16(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Название',
                  border: StyleHelper.outlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              StyleHelper.sizedBox8(),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: StyleHelper.outlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              StyleHelper.sizedBox8(),
              TextField(
                controller: _photoLinkController,
                decoration: InputDecoration(
                  labelText: 'Ссылка на фото',
                  border: StyleHelper.outlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              StyleHelper.sizedBox24(),
              DropdownSearch<CategoryModel>(
                compareFn: (category, filter) => true,
                items: (String filter, _) async => await _fetchCategories(filter),
                itemAsString: (CategoryModel c) => c.name,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true,
                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    hintText: 'Категория',
                    border: StyleHelper.outlineInputBorder(),
                  ),
                ),
                selectedItem: _category,
                onChanged: (value) {
                  _category = value;
                },
              ),
              StyleHelper.sizedBox24(),
              Text("Шаги рецепта:", style: StyleHelper.textFontSize18FontWeight600()),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return steps[index];
                },
              ),
              StyleHelper.sizedBox4(),
              ElevatedButton(
                onPressed: _addStep,
                style: StyleHelper.buttonStyleAdmin(Colors.blueAccent),
                child: Text("Добавить шаг", style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
              ),
              StyleHelper.sizedBox24(),
              Text("Ингредиенты:", style: StyleHelper.textFontSize18FontWeight600()),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return ingredients[index];
                },
              ),
              StyleHelper.sizedBox4(),
              ElevatedButton(
                onPressed: _addIngredient,
                style: StyleHelper.buttonStyleAdmin(Colors.blueAccent),
                child: Text("Добавить ингредиент", style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
              ),
              StyleHelper.sizedBox24(),
              ElevatedButton(
                onPressed: isEnableSaveButton() ? _fetchCreateRecipe : null,
                style: StyleHelper.buttonStyleAdmin(Colors.blueAccent),
                child: Text("Создать рецепт", style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeStepWidget extends StatelessWidget {
  final int index;

  RecipeStepWidget({required this.index});

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: StyleHelper.edgeInsetsSymV8(),
      child: Padding(
        padding: StyleHelper.edgeInsetsAll8(),
        child: Column(
          crossAxisAlignment: StyleHelper.crossAxisAlignmentStretch(),
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Описание шага",
                border: StyleHelper.outlineInputBorder()
              ),
            ),
            StyleHelper.sizedBox8(),
            TextField(
              controller: _photoLinkController,
              decoration: InputDecoration(
                labelText: "Ссылка на фото",
                border: StyleHelper.outlineInputBorder()
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeIngredientWidget extends StatelessWidget {
  final TextEditingController _quantityController = TextEditingController();
  Map<UnitOfMeasure, String>? _unitOfMeasure;
  ProductModel? _productModel;

  Future<List<ProductModel>> _fetchProducts(String text) async {
    List<ProductModel> parseProducts(List<dynamic> data) {
      return data.map((json) {
        return ProductModel.fromJson(json);
      }).toList();
    }

    List<ProductModel> products = [];

    var body = await HttpHelper.get('/api/product/all', {
      'Page': '0',
      'Search': text
    });

    List<dynamic> jsonData = json.decode(body);
    products = parseProducts(jsonData);

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: StyleHelper.edgeInsetsSymV8(),
      child: Padding(
        padding: StyleHelper.edgeInsetsAll8(),
        child: Column(
          crossAxisAlignment: StyleHelper.crossAxisAlignmentStretch(),
          children: [
            DropdownSearch<ProductModel>(
              compareFn: (category, filter) => true,
              items: (String filter, _) async => await _fetchProducts(filter),
              itemAsString: (ProductModel p) => p.name,
              popupProps: StyleHelper.propsProductModel(),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: 'Продукт',
                  border: StyleHelper.outlineInputBorder(),
                ),
              ),
              selectedItem: _productModel,
              onChanged: (value) {
                _productModel = value;
              },
            ),
            StyleHelper.sizedBox8(),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Количество",
                border: StyleHelper.outlineInputBorder()
              ),
            ),
            StyleHelper.sizedBox8(),
            DropdownSearch<Map<UnitOfMeasure, String>>(
              compareFn: (category, filter) => true,
              items: (String filter, _) => EnumHelper.unitOfMeasures,
              itemAsString: (Map<UnitOfMeasure, String> u) => u.values.first,
              popupProps: StyleHelper.propsUnitOfMeasure(),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  hintText: 'Единица измерения',
                  border: StyleHelper.outlineInputBorder(),
                ),
              ),
              selectedItem: _unitOfMeasure,
              onChanged: (value) {
                _unitOfMeasure = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}