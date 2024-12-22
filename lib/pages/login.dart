import 'admin.dart';
import 'dart:convert';
import '../pages/recipes.dart';
import '../pages/register.dart';
import '../models/auth_models.dart';
import '../helpers/auth_helper.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isEnableSaveButton() {
    return _loginController.text.trim() != '' && _passwordController.text.trim() != '';
  }

  Future<void> _fetchLogin() async {

    AuthResponseModel parseResponseAuth(Map<String, dynamic> data) {
      return AuthResponseModel.fromJson(data);
    }

    var body = await HttpHelper.post('/api/auth/login',
        <String, String>{'login': _loginController.text, 'password': _passwordController.text},
        context
    );

    if (body == '') {
      return;
    }

    Map<String, dynamic> jsonData = jsonDecode(body);
    var authModel = parseResponseAuth(jsonData);

    await AuthHelper.login(authModel);

    if (authModel.role == UserRole.administrator) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => AdminHomePage()
          ),
          (route) => false
      );
    }
    else{
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
        title: const Text('Вход'),
      ),
      body: Padding(
        padding: StyleHelper.edgeInsetsAll8(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Логин',
                border: StyleHelper.outlineInputBorder()
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            StyleHelper.sizedBox16(),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: StyleHelper.outlineInputBorder()
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {});
              },
            ),
            StyleHelper.sizedBox16(),
            ElevatedButton(
              onPressed: isEnableSaveButton() ? () {
                _fetchLogin();
              } : null,
              child: const Text('Войти'),
            ),
            StyleHelper.sizedBox16(),
            InkWell(
              child:
              Text('Нет аккаунта? Зарегистрироваться',
                  style: StyleHelper.textColorBlueDecUnderline()
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()
                    )
                );
              }
            )
          ],
        ),
      ),
    );
  }
}