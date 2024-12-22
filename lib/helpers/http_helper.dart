import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cook_book_frontend/helpers/auth_helper.dart';
import 'package:cook_book_frontend/helpers/dialog_helper.dart';

class HttpHelper {
  static String basePath = "localhost:7152";

  static Future<String> get(String endpoint, Map<String, dynamic> query) async {
    //await Future.delayed(const Duration(seconds: 1));

    final response =
        await http.get(Uri.https(basePath, endpoint, query),
            headers: <String, String> {
              'Authorization': 'Bearer ${await AuthHelper.getToken()}'
            }
        );

    if (response.statusCode == 200) {
      return response.body;
    }
    else {
      return '';
    }
  }

  static Future<String> post(String endpoint, Object body, BuildContext context) async {
    final response =
    await http.post(Uri.https(basePath, endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await AuthHelper.getToken()}'
      },
      body: jsonEncode(body)
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    else {
      await DialogHelper.show("Ошибка", response.body, context);
      return '';
    }
  }
  static Future<String> patch(String endpoint, Object body, BuildContext context) async {
    final response =
    await http.patch(Uri.https(basePath, endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await AuthHelper.getToken()}'
        },
        body: jsonEncode(body)
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    else {
      await DialogHelper.show("Ошибка", response.body, context);
      return '';
    }
  }

  static Future<String> delete(String endpoint, BuildContext context) async {
    final response =
    await http.delete(Uri.https(basePath, endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await AuthHelper.getToken()}'
        }
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    else {
      await DialogHelper.show("Ошибка", response.body, context);
      return '';
    }
  }
}