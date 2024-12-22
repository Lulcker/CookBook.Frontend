import 'dart:convert';
import '../pages/admin.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import '../models/recipe_models.dart';
import 'package:flutter/material.dart';
import '../pages/recipe_full_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ModerationRecipesPage extends StatefulWidget {

  @override
  _ModerationRecipesPageState createState() => _ModerationRecipesPageState();
}

class _ModerationRecipesPageState extends State<ModerationRecipesPage> {
  final List<RecipeModel> _recipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initTasks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchModerationRecipes();
      }
    });
  }

  void initTasks() async {
    await _fetchModerationRecipes();
  }

  Future<void> _fetchModerationRecipes() async {
    setState(() {
      _isLoading = true;
    });

    List<RecipeModel> parseRecipes(List<dynamic> data) {
      return data.map((json) {
        return RecipeModel.fromJson(json);
      }).toList();
    }

    List<RecipeModel> newRecipes = [];

    var body = await HttpHelper.get('/api/recipe/all-moderation', {
      'Page': _page.toString(),
    });

    List<dynamic> jsonData = json.decode(body);
    newRecipes = parseRecipes(jsonData);

    setState(() {
      _isLoading = false;
      _page++;
      _recipes.addAll(newRecipes);
      if (newRecipes.length < 5) {
        _hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminHomePage()
                  ),
                      (route) => false
              );
            },
          ),
          title: const Text('Рецепты на одобрение'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  if (index == _recipes.length) {
                    return _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  RecipeModel recipe = _recipes[index];
                  return ModerationRecipeCard(recipe: recipe);
                },
              ),
            ),
            if (_hasMore) ElevatedButton(
              onPressed: () async {
                await _fetchModerationRecipes();
              },
              style: StyleHelper.buttonStyleAdmin(Colors.cyan),
              child: Text('Показать ещё', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
            )
            else Container()
          ],
        )
    );
  }
}

class ModerationRecipeCard extends StatefulWidget {
  final RecipeModel recipe;

  const ModerationRecipeCard({required this.recipe});

  @override
  _ModerationRecipeCardState createState() => _ModerationRecipeCardState();
}

class _ModerationRecipeCardState extends State<ModerationRecipeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  RecipePage(recipeId: widget.recipe.id)));
        },
        child: Card(
          margin: StyleHelper.edgeInsetsSymV8H16(),
          child: Padding(
            padding: StyleHelper.edgeInsetsAll8(),
            child: Row(
              children: [
                Padding(
                  padding: StyleHelper.edgeInsetsOnlyRight16(),
                  child: ClipRRect(
                    borderRadius: StyleHelper.borderRadius8(),
                    child:  CachedNetworkImage(
                      imageUrl: widget.recipe.photoLink,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  ),
                ),
                StyleHelper.sizedBox16(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: StyleHelper.crossAxisAlignmentStart(),
                    children: [
                      Text(widget.recipe.name,
                        style: StyleHelper.textFontSize16FontWeightBold(),
                      ),
                      StyleHelper.sizedBox4(),
                      Text('Состав: ${widget.recipe.ingredients}',
                        style: StyleHelper.textColorGrey(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}