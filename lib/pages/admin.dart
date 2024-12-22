import 'categories.dart';
import '../pages/recipes.dart';
import '../pages/products.dart';
import 'moderation_recipe.dart';
import '../helpers/http_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/style_helper.dart';
import 'package:flutter/material.dart';
import '../helpers/dialog_helper.dart';

class AdminHomePage extends StatefulWidget {

  @override
  _AdminHomePagePageState createState() => _AdminHomePagePageState();
}

class _AdminHomePagePageState extends State<AdminHomePage> {
  int _countRecipesForModeration = 0;

  @override
  void initState() {
    super.initState();
    initTasks();
  }

  void initTasks() async {
    await _fetchCountRecipesForModeration();
  }

  Future<void> _fetchCountRecipesForModeration() async {
    int count = 0;

    var body = await HttpHelper.get('/api/recipe/count-moderation', {});

    if (body != '') {
      count = int.parse(body);
    }

    setState(() {
      _countRecipesForModeration = count;
    });
  }

  void logoutOnclick() async {
    bool result = await DialogHelper
        .showConfirm('Вы точно хотите выйти из аккаунта?', context);

    if (result) {
      await AuthHelper.logout();

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
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                logoutOnclick();
              });
            },
            child: const Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: StyleHelper.edgeInsetsAll16(),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ModerationRecipesPage()),
                          (route) => false,
                    );
                  },
                  style: StyleHelper.buttonStyleAdmin(Colors.cyan),
                  child: Text('Новые рецепты', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
                ),
                if (_countRecipesForModeration > 0)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Text(_countRecipesForModeration.toString(),
                        style: StyleHelper.textFontSize10ColorWhite(),
                      ),
                    ),
                  ),
              ],
            ),
            StyleHelper.sizedBox16(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                      (route) => false,
                );
              },
              style: StyleHelper.buttonStyleAdmin(Colors.blueAccent),
              child: Text('Продукты', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
            ),
            StyleHelper.sizedBox16(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()),
                      (route) => false,
                );
              },
              style: StyleHelper.buttonStyleAdmin(Colors.lightGreen),
              child: Text('Категории', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
            ),
          ],
        ),
      ),
    );
  }
}