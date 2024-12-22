import 'dart:convert';
import '../pages/admin.dart';
import '../models/auth_models.dart';
import '../helpers/auth_helper.dart';
import '../helpers/http_helper.dart';
import '../helpers/style_helper.dart';
import '../helpers/dialog_helper.dart';
import '../models/product_models.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  AuthResponseModel authInfo = emptyAuthModel;
  final List<ProductModel> _products = [];
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
        _fetchProducts();
      }
    });
  }

  void initTasks() async {
    await setAuth();
    await _fetchProducts();
  }

  Future<void> setAuth() async {
    authInfo = await AuthHelper.init();
  }

  Future<void> _updateProducts() async {
    _page = 0;
    _products.clear();
    await _fetchProducts();
    setState(() {});
  }

  Future<void> _fetchAddProduct(CreateProductModel model) async {
    await HttpHelper.post('/api/product/create', model, context);
    await _updateProducts();
  }

  Future<void> _fetchUpdateProduct(UpdateProductModel model) async {
    await HttpHelper.patch('/api/product/update', model, context);
    await _updateProducts();
  }

  Future<void> _fetchDeleteProduct(String id) async {
    await HttpHelper.delete('/api/product/$id', context);
    await _updateProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    List<ProductModel> parseProducts(List<dynamic> data) {
      return data.map((json) {
        return ProductModel.fromJson(json);
      }).toList();
    }

    List<ProductModel> newProducts = [];

    var body = await HttpHelper.get('/api/product/all', {
      'Page': _page.toString(),
      'OrderBy': _sortOrder,
      'Search': _searchController.text
    });

    List<dynamic> jsonData = json.decode(body);
    newProducts = parseProducts(jsonData);

    setState(() {
      _isLoading = false;
      _page++;
      _products.addAll(newProducts);
      if (newProducts.length < 5) {
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
                    builder: (context) => AdminHomePage()),
                    (route) => false);
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
                    await _updateProducts();
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
                    await _updateProducts();
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
              itemCount: _products.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _products.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }
                ProductModel product = _products[index];
                return ProductCard(product: product, authInfo: authInfo, updateTask: _fetchUpdateProduct, deleteTask: _fetchDeleteProduct,);
              },
            ),
          ),
          if (_hasMore) ElevatedButton(
            onPressed: () async {
              await _fetchProducts();
            },
            style: StyleHelper.buttonStyleAdmin(Colors.cyan),
            child: Text('Показать ещё', style: StyleHelper.textFontSize16ColorWhiteFontWeight400()),
          )
          else Container()
        ],
      ),
      floatingActionButton: authInfo.isAuthorized && authInfo.role == UserRole.administrator ? FloatingActionButton(
        onPressed: () async {
          var result = await DialogHelper.showAddProduct(context);
          if (result != null) {
            await _fetchAddProduct(result);
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final AuthResponseModel authInfo;
  final Function(UpdateProductModel) updateTask;
  final Function(String) deleteTask;

  const ProductCard({
    required this.product,
    required this.authInfo,
    required this.updateTask,
    required this.deleteTask
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: StyleHelper.edgeInsetsSymV8H16(),
      child: Padding(
          padding: StyleHelper.edgeInsetsAll8(),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: StyleHelper.crossAxisAlignmentStart(),
                children: [
                  Text(
                    widget.product.name,
                    style: StyleHelper.textFontSize16FontWeightBold(),
                  ),
                ],
              ),
            ),
            if (widget.authInfo.role == UserRole.administrator)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) async {
                  if (value == 'edit') {
                    var result = await DialogHelper.showUpdateProduct(widget.product, context);
                    if (result != null) {
                      widget.updateTask(result);
                    }
                  }
                  if (value == 'delete') {
                    var result = await DialogHelper.showConfirm('Вы точно хотите удалить продукт ${widget.product.name}?', context);
                    if (result) {
                      widget.deleteTask(widget.product.id);
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
    );
  }
}