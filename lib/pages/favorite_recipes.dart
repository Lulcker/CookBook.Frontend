import 'dart:convert';
import '../pages/recipes.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import '../models/recipe_models.dart';
import 'package:flutter/material.dart';
import '../helpers/dialog_helper.dart';
import '../pages/recipe_full_info.dart';

class FavoriteRecipesPage extends StatefulWidget {

  @override
  _FavoriteRecipesPageState createState() => _FavoriteRecipesPageState();
}

class _FavoriteRecipesPageState extends State<FavoriteRecipesPage> {
  final List<FavoriteRecipeModel> _recipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  String _sortOrder = 'added_at_desc';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTasks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchFavoriteRecipes();
      }
    });
  }

  void initTasks() async {
    await _fetchFavoriteRecipes();
  }

  Future<void> _fetchFavoriteRecipes() async {
    setState(() {
      _isLoading = true;
    });

    List<FavoriteRecipeModel> parseRecipes(List<dynamic> data) {
      return data.map((json) {
        return FavoriteRecipeModel.fromJson(json);
      }).toList();
    }

    List<FavoriteRecipeModel> newRecipes = [];

    var body = await HttpHelper.get('/api/favorite-recipe/all', {
      'Page': _page.toString(),
      'OrderBy': _sortOrder,
      'Search': _searchController.text
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

  void _onDelete(String recipeId) {
    setState(() {
      _recipes.removeWhere((r) => r.recipeId == recipeId);
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
                    builder: (context) => RecipesPage(categoryId: null)
                ),
                (route) => false
            );
          },
        ),
        title: const Text('CookBook'),
      ),
      body: Column(
        children: [
          Padding(
            padding: StyleHelper.edgeInsetsAll8(),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _page = 0;
                      _recipes.clear();
                      _fetchFavoriteRecipes();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск рецептов',
                    border: StyleHelper.outlineInputBorder(),
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortOrder,
                  icon: const Icon(Icons.sort),
                  onChanged: (value) {
                    setState(() {
                      _sortOrder = value!;
                      _page = 0;
                      _recipes.clear();
                      _fetchFavoriteRecipes();
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'added_at_desc',
                        child: Text('Последние добавленные')),
                    DropdownMenuItem(
                        value: 'added_at_asc',
                        child: Text('Первые добавленные')),
                    DropdownMenuItem(
                        value: 'name_asc',
                        child: Text('В алфавитном порядке А-я')),
                    DropdownMenuItem(
                        value: 'name_desc',
                        child: Text('В обратном алфавитном порядке Я-а'))
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _recipes.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _recipes.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }
                FavoriteRecipeModel recipe = _recipes[index];
                return FavoriteRecipeCard(recipe: recipe, onDeleteChanged: _onDelete);
              },
            ),
          ),
          if (_hasMore) ElevatedButton(
            onPressed: () async {
              await _fetchFavoriteRecipes();
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

class FavoriteRecipeCard extends StatefulWidget {
  final FavoriteRecipeModel recipe;
  final Function(String) onDeleteChanged;

  const FavoriteRecipeCard({super.key, required this.recipe, required this.onDeleteChanged});

  @override
  _FavoriteRecipeCardState createState() => _FavoriteRecipeCardState();
}

class _FavoriteRecipeCardState extends State<FavoriteRecipeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  RecipePage(recipeId: widget.recipe.recipeId)));
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
                  child: Image.network(
                    widget.recipe.photoLink,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              StyleHelper.sizedBox16(),
              Expanded(
                child: Column(
                  crossAxisAlignment: StyleHelper.crossAxisAlignmentStart(),
                  children: [
                    Text(
                      widget.recipe.name,
                      style: StyleHelper.textFontSize16FontWeightBold(),
                    ),
                    StyleHelper.sizedBox4(),
                    Text('Состав: ${widget.recipe.ingredients}',
                      style: StyleHelper.textColorGrey(),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  if (!await DialogHelper.showConfirm('Вы точно хотите удалить рецепт из избранного?', context)) {
                    return;
                  }

                  await HttpHelper.delete('api/favorite-recipe/${widget.recipe.recipeId}', context);
                  widget.onDeleteChanged(widget.recipe.recipeId);
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}