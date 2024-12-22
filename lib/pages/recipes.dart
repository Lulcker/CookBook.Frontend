import 'dart:convert';
import 'create_recipe.dart';
import '../pages/login.dart';
import '../pages/categories.dart';
import '../models/auth_models.dart';
import '../helpers/http_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/style_helper.dart';
import '../models/recipe_models.dart';
import 'package:flutter/material.dart';
import '../helpers/dialog_helper.dart';
import '../pages/favorite_recipes.dart';
import '../pages/recipe_full_info.dart';

class RecipesPage extends StatefulWidget {
  final String? categoryId;

  RecipesPage({required this.categoryId});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  AuthResponseModel authInfo = emptyAuthModel;
  final List<RecipeModel> _recipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  int _countFavorite = 0;
  String _sortOrder = 'created_at_desc';

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
        _fetchRecipes();
      }
    });
  }

  void initTasks() async {
    await setAuth();
    await _fetchRecipes();

    if (authInfo.isAuthorized) {
      await _fetchFavoriteCount();
    }
  }

  Future<void> setAuth() async {
    authInfo = await AuthHelper.init();
  }

  Future<void> _fetchFavoriteCount() async {
    setState(() {
      _isLoading = true;
    });

    int count = 0;

    var body = await HttpHelper.get('/api/favorite-recipe/count', {});

    if (body != '') {
      count = int.parse(body);
    }

    setState(() {
      _countFavorite = count;
      _isLoading = false;
    });
  }

  void _updateFavoriteCount(bool added) {
    setState(() {
      if (added) {
        _countFavorite += 1;
      }
      else{
        _countFavorite -= 1;
      }
    });
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    List<RecipeModel> parseRecipes(List<dynamic> data) {
      return data.map((json) {
        return RecipeModel.fromJson(json);
      }).toList();
    }

    List<RecipeModel> newRecipes = [];

    var body = await HttpHelper.get('/api/recipe/all', {
      'Page': _page.toString(),
      'OrderBy': _sortOrder,
      'Search': _searchController.text,
      'CategoryId': widget.categoryId
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

  void loginOnclick() async {
    if (authInfo.isAuthorized) {
      bool result = await DialogHelper
          .showConfirm('Вы точно хотите выйти из аккаунта?', context);

      if (result) {
        authInfo = await AuthHelper.logout();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => RecipesPage(categoryId: null)
            ),
            (route) => false
        );
      }
    }
    else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
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
        leading: IconButton(
          icon: const Icon(Icons.category),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => CategoriesPage()
              )
            );
          },
        ),
        title: const Text('CookBook'),
        actions: [
          authInfo.isAuthorized && authInfo.role != UserRole.administrator ?
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  IconButton(
                      icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoriteRecipesPage()
                          ),
                          (route) => false
                      );
                    },
                  ),
                  if (_countFavorite > 0)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.blue,
                        child: Text(
                          _countFavorite.toString(),
                          style: StyleHelper.textFontSize10ColorWhite(),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          )
              : Container(),
          TextButton(
            child: authInfo.isAuthorized
                ? Text(authInfo.login)
                : const Icon(Icons.person),
            onPressed: () {
              setState(() {
                loginOnclick();
              });
            },
          ),
        ],
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
                      _fetchRecipes();
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
                      _fetchRecipes();
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'rating_asc',
                        child: Text('По возрастанию рейтинга')),
                    DropdownMenuItem(
                        value: 'rating_desc',
                        child: Text('По убыванию рейтинга')),
                    DropdownMenuItem(
                        value: 'created_at_asc',
                        child: Text('Первые добавленные')),
                    DropdownMenuItem(
                        value: 'created_at_desc',
                        child: Text('Самые новые')),
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
                RecipeModel recipe = _recipes[index];
                return RecipeCard(recipe: recipe, isAuthorized: authInfo.isAuthorized, onFavoriteChanged: _updateFavoriteCount);
              },
            ),
          ),
          if (_hasMore) ElevatedButton(
              onPressed: () async {
                await _fetchRecipes();
              },
              style: StyleHelper.buttonStyleAdmin(Colors.cyan),
              child: Text('Показать ещё', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
            )
          else Container(),
        ],
      ),
      floatingActionButton: authInfo.isAuthorized ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => CreateRecipePage()
              )
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

class RecipeCard extends StatefulWidget {
  final RecipeModel recipe;
  final bool isAuthorized;
  final Function(bool) onFavoriteChanged;

  const RecipeCard({required this.recipe, required this.isAuthorized, required this.onFavoriteChanged});

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
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
                  StyleHelper.sizedBox4(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.recipe.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow[700],
                      );
                    }),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                widget.recipe.isAddedToFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () async {
                if (!widget.isAuthorized) {
                  await DialogHelper.show(
                      "Внимание",
                      "Для добавления рецепта в избранное нужно авторизоваться",
                      context);

                  return;
                }
                if (widget.recipe.isAddedToFavorite) {
                  await HttpHelper.delete("/api/favorite-recipe/${widget.recipe.id}", context);
                }
                else {
                  await HttpHelper.post("/api/favorite-recipe/add", widget.recipe.id, context);
                }
                setState(() {
                  widget.recipe.isAddedToFavorite = !widget.recipe.isAddedToFavorite;
                  widget.onFavoriteChanged(widget.recipe.isAddedToFavorite);
                });
              },
            ),
          ],
        ),
      ),
    )
    );
  }
}
