import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/auth_models.dart';
import '../helpers/http_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/style_helper.dart';
import '../models/recipe_models.dart';
import 'package:flutter/material.dart';
import '../pages/moderation_recipe.dart';

class RecipePage extends StatefulWidget {
  final String? recipeId;

  RecipePage({required this.recipeId});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  RecipeFullInfoModel? recipe;
  bool isAdmin = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    initTasks();
  }

  void initTasks() async {
    await _fetchRecipe();
    await _checkIsAdmin();
  }

  Future<void> _checkIsAdmin() async {
    var authInfo = await AuthHelper.init();

    isAdmin = authInfo.role == UserRole.administrator;
  }

  Future<void> _fetchRecipe() async {
    var body = await HttpHelper.get('/api/recipe/${widget.recipeId}', <String, String>{});

    if (body == '') {
      return;
    }

    Map<String, dynamic> jsonData = jsonDecode(body);
    setState(() {
      recipe = RecipeFullInfoModel.fromJson(jsonData);
    });
  }

  Future<void> _fetchAcceptRecipe() async {
    var body = ApproveRecipeModel(
        id: recipe!.id,
        name: recipe!.name,
        description: recipe!.description
    ).toJson();

    await HttpHelper.patch('api/recipe/approve', body, context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ModerationRecipesPage()
        ),
            (route) => false
    );
  }

  Future<void> _fetchRejectRecipe() async {
    var body = RejectRecipeModel(
        id: recipe!.id,
        comment: 'Рецепт не корректный',
    ).toJson();

    await HttpHelper.patch('api/recipe/reject', body, context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ModerationRecipesPage()
        ),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: recipe == null
            ? const CircularProgressIndicator()
            : Text(recipe!.name),
      ),
      body: recipe == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
         child: Padding(
          padding: StyleHelper.edgeInsetsAll16(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: recipe!.photoLink,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              StyleHelper.sizedBox16(),
              Text(recipe!.name,
                  style: StyleHelper.textFontSize24FontWeightBold()
              ),
              StyleHelper.sizedBox8(),
              Text('Описание: ${recipe!.description}',
                  style: StyleHelper.textFontSize16()
              ),
              StyleHelper.sizedBox8(),
              Text('Категория: ${recipe!.categoryName}',
                  style: StyleHelper.textFontSize16()
              ),
              StyleHelper.sizedBox8(),
              Text('Рейтинг: ${recipe!.rating}',
                  style: StyleHelper.textFontSize16()
              ),
              StyleHelper.sizedBox8(),
              Text('Автор: ${recipe!.userLogin}',
                  style: StyleHelper.textFontSize16()
              ),
              StyleHelper.sizedBox16(),
              Text('Ингредиенты:',
                  style: StyleHelper.textFontSize20FontWeightBold()
              ),
              for (var ingredient in recipe!.ingredients)
                Padding(
                  padding: StyleHelper.edgeInsetsSymV8(),
                  child: Text('${ingredient.productName}: ${ingredient.quantity} ${EnumHelper.getMeasure(ingredient.unitOfMeasure)}', style: StyleHelper.textFontSize16()),
                ),
              StyleHelper.sizedBox16(),
              Text('Шаги рецепта:', style: StyleHelper.textFontSize20FontWeightBold()),
              for (var step in recipe!.recipeSteps)
                Padding(
                  padding: StyleHelper.edgeInsetsSymV8(),
                  child: Column(
                    crossAxisAlignment: StyleHelper.crossAxisAlignmentStart(),
                    children: [
                      CachedNetworkImage(
                        imageUrl: step.photoLink!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      StyleHelper.sizedBox8(),
                      Text(step.description, style: StyleHelper.textFontSize16()),
                    ],
                  ),
                ),
              if (isAdmin)
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Принять'),
                        value: 0,
                        groupValue: _selectedOption,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Отклонить'),
                        value: 1,
                        groupValue: _selectedOption,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      ),
                    ),
                    StyleHelper.sizedBox16(),
                    ElevatedButton(
                      onPressed: _selectedOption != null ? () async {
                        if (_selectedOption == 0) {
                          await _fetchAcceptRecipe();
                        } else {
                          await _fetchRejectRecipe();
                        }
                      } : null,
                      style: StyleHelper.buttonStyleAdmin(Colors.blueAccent),
                      child: Text('Сохранить', style: StyleHelper.textColorWhite()),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}