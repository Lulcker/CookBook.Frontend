import 'admin.dart';
import '../pages/recipes.dart';
import '../models/auth_models.dart';
import '../helpers/auth_helper.dart';
import '../helpers/style_helper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {

  Future<bool> isAdmin() async {
    var result = await AuthHelper.init();
    return result.isAuthorized && result.role == UserRole.administrator;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      var result = await AuthHelper.init();

      if (result.isAuthorized && result.role == UserRole.administrator) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      }
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecipesPage(categoryId: null)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'Добро пожаловать в CookBook!',
          style: StyleHelper.textFontSize24ColorWhite(),
        ),
      ),
    );
  }
}