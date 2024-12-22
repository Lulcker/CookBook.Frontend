import 'dart:convert';
import '../pages/admin.dart';
import '../pages/recipes.dart';
import '../models/auth_models.dart';
import '../helpers/auth_helper.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import 'package:flutter/material.dart';
import '../helpers/dialog_helper.dart';
import '../models/category_models.dart';

class CategoriesPage extends StatefulWidget {

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  AuthResponseModel authInfo = emptyAuthModel;
  final List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  String _sortOrder = 'name_asc';

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
        _fetchCategories();
      }
    });
  }

  void initTasks() async {
    await setAuth();
    await _fetchCategories();
  }

  Future<void> setAuth() async {
    authInfo = await AuthHelper.init();
  }

  Future<void> _updateCategories() async {
    _page = 0;
    _categories.clear();
    await _fetchCategories();
  }

  Future<void> _fetchAddCategory(CreateCategoryModel model) async {
    await HttpHelper.post('/api/category/create', model, context);
    await _updateCategories();
  }

  Future<void> _fetchUpdateCategory(UpdateCategoryModel model) async {
    await HttpHelper.patch('/api/category/update', model, context);
    await _updateCategories();
  }

  Future<void> _fetchDeleteCategory(String id) async {
    await HttpHelper.delete('/api/category/$id', context);
    await _updateCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    List<CategoryModel> parseCategories(List<dynamic> data) {
      return data.map((json) {
        return CategoryModel.fromJson(json);
      }).toList();
    }

    List<CategoryModel> newCategories = [];

    var body = await HttpHelper.get('/api/category/all', {
      'Page': _page.toString(),
      'OrderBy': _sortOrder,
      'Search': _searchController.text
    });

    List<dynamic> jsonData = json.decode(body);
    newCategories = parseCategories(jsonData);

    setState(() {
      _isLoading = false;
      _page++;
      _categories.addAll(newCategories);
      if (newCategories.length < 5) {
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
              if (authInfo.role == UserRole.administrator) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminHomePage()),
                        (route) => false);
              }
              else{
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecipesPage(categoryId: null)),
                        (route) => false);
              }
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
                    onChanged: (value) async {
                      await _updateCategories();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Поиск категорий',
                      border: StyleHelper.outlineInputBorder(),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortOrder,
                    icon: const Icon(Icons.sort),
                    onChanged: (value) async {
                      setState(() {
                        _sortOrder = value!;
                      });
                      await _updateCategories();
                    },
                    items: const [
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
                itemCount: _categories.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _categories.length) {
                    return _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  CategoryModel category = _categories[index];
                  return CategoryCard(category: category, authInfo: authInfo, updateTask: _fetchUpdateCategory, deleteTask: _fetchDeleteCategory,);
                },
              ),
            ),
            if (_hasMore) ElevatedButton(
              onPressed: () async {
                await _fetchCategories();
              },
              style: StyleHelper.buttonStyleAdmin(Colors.cyan),
              child: Text('Показать ещё', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
            )
            else Container()
          ],
        ),
      floatingActionButton: authInfo.isAuthorized && authInfo.role == UserRole.administrator ? FloatingActionButton(
        onPressed: () async {
          var result = await DialogHelper.showAddCategory(context);
          if (result != null) {
            await _fetchAddCategory(result);
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final AuthResponseModel authInfo;
  final Function(UpdateCategoryModel) updateTask;
  final Function(String id) deleteTask;

  const CategoryCard({
    required this.category,
    required this.authInfo,
    required this.updateTask,
    required this.deleteTask
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  RecipesPage(categoryId: widget.category.id)));
        },
        child: Card(
            margin: StyleHelper.edgeInsetsSymV8H16(),
            child: Padding(
                padding: StyleHelper.edgeInsetsAll8(),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: StyleHelper.textFontSize16FontWeightBold(),
                        ),
                        StyleHelper.sizedBox4(),
                        Text(
                          'Описание: ${widget.category.description}',
                          style: StyleHelper.textColorGrey(),
                        ),
                      ],
                    ),
                  ),
                  if (widget.authInfo.role == UserRole.administrator)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) async {
                        if (value == 'edit') {
                          var result = await DialogHelper.showUpdateCategory(widget.category, context);
                          if (result != null) {
                            setState(() {
                              widget.updateTask(result);
                            });
                          }
                        }
                        if (value == 'delete') {
                          var result = await DialogHelper.showConfirm('Вы точно хотиту удалить категорию ${widget.category.name}?', context);
                          if (result) {
                            setState(() {
                              widget.deleteTask(widget.category.id);
                            });
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Редактировать'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Удалить'),
                          )
                        ];
                      },
                    ),
                ]
              )
            )
        )
    );
  }
}
