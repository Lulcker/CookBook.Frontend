import 'dart:convert';
import '../pages/login.dart';
import '../pages/recipes.dart';
import '../models/auth_models.dart';
import '../helpers/auth_helper.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import 'package:flutter/material.dart';
import '../helpers/dialog_helper.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAccepted = false;

  bool isEnableSaveButton() {
    return _loginController.text.trim() != '' && _passwordController.text.trim() != '' && _confirmPasswordController.text.trim() != '' && _isAccepted;
  }

  Future<void> _fetchLogin() async {

    AuthResponseModel parseResponseAuth(Map<String, dynamic> data) {
      return AuthResponseModel.fromJson(data);
    }

    var body = await HttpHelper.post('/api/auth/registration-customer',
        <String, String>{'login': _loginController.text, 'password': _passwordController.text},
        context
    );

    if (body == '') {
      return;
    }

    Map<String, dynamic> jsonData = jsonDecode(body);
    var authModel = parseResponseAuth(jsonData);

    await AuthHelper.login(authModel);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => RecipesPage(categoryId: null)
        ),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: StyleHelper.edgeInsetsAll16(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Логин',
                border: StyleHelper.outlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              }
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
              }
            ),
            StyleHelper.sizedBox16(),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Подтверждение пароля',
                border: StyleHelper.outlineInputBorder()
              ),
              obscureText: true,
              onChanged: (value) {
                setState(() {});
              }
            ),
            StyleHelper.sizedBox16(),
            CheckboxListTile(
              title: const Text('Принимаю пользовательские соглашения'),
              value: _isAccepted,
              onChanged: (newValue) {
                setState(() {
                  _isAccepted = newValue ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            StyleHelper.sizedBox16(),
            ElevatedButton(
              onPressed: isEnableSaveButton() ? () async {
                if (_passwordController.text != _confirmPasswordController.text) {
                  await DialogHelper.show('Ошибка', 'Пароли не совпадают', context);
                  return;
                }

                await _fetchLogin();
              } : null,
              child: const Text('Зарегистрироваться'),
            ),
            StyleHelper.sizedBox16(),
            InkWell(child: Text(
              'Есть аккаунт? Войти',
              style: StyleHelper.textColorBlueDecUnderline()
            ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()
                    )
                );
              },
            )
          ],
        ),
      ),
    );
  }
}