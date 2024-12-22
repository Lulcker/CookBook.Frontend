import '../models/product_models.dart';
import 'package:flutter/material.dart';
import '../models/category_models.dart';

class DialogHelper {
  static Future<void> show(String title, String errorMessage, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ок'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirm(String answer, BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Подтверждение'),
            content: Text(answer),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text('Да'),
              ),
            ],
          );
        }
    );
  }

  static Future<bool> showSuccess(String message, BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Успешно!'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text('Закрыть'),
              ),
            ],
          );
        }
    );
  }

  static Future<UpdateCategoryModel?> showUpdateCategory(CategoryModel category, BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    nameController.text = category.name;
    descriptionController.text = category.description;

    UpdateCategoryModel? updateCategoryModel;

    void fillModel() {
      updateCategoryModel = UpdateCategoryModel(id: category.id, name: nameController.text, description: descriptionController.text);
    }

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Обновление категории'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(null);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                fillModel();
                Navigator.of(context, rootNavigator: true).pop(updateCategoryModel);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  static Future<CreateCategoryModel?> showAddCategory(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    CreateCategoryModel? createCategoryModel;

    void fillModel() {
      createCategoryModel = CreateCategoryModel(name: nameController.text, description: descriptionController.text);
    }

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Создание категории'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(null);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                fillModel();
                Navigator.of(context, rootNavigator: true).pop(createCategoryModel);
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  static Future<UpdateProductModel?> showUpdateProduct(ProductModel product, BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = product.name;

    UpdateProductModel? updateProductModel;

    void fillModel() {
      updateProductModel = UpdateProductModel(id: product.id, name: nameController.text);
    }

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Обновление продукта'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
              constraints: const BoxConstraints(
              maxHeight: 150,
            ),
              child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(null);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  fillModel();
                  Navigator.of(context, rootNavigator: true).pop(updateProductModel);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        }
    );
  }

  static Future<CreateProductModel?> showAddProduct(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    CreateProductModel? createProductModel;

    void fillModel() {
      createProductModel = CreateProductModel(name: nameController.text);
    }

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Создание продукта'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                      ),
                      onChanged: (value) {
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(null);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  fillModel();
                  Navigator.of(context, rootNavigator: true).pop(createProductModel);
                },
                child: const Text('Создать'),
              ),
            ],
          );
        }
    );
  }
}