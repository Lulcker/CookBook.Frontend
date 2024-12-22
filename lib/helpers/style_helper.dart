import '../models/recipe_models.dart';
import '../models/product_models.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class StyleHelper{
  static TextStyle textFontSize24ColorWhite() {
    return const TextStyle(fontSize: 24, color: Colors.white);
  }

  static TextStyle textFontSize16ColorWhiteFontWeight400() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white);
  }

  static TextStyle textFontSize10ColorWhite() {
    return const TextStyle(fontSize: 10, color: Colors.white);
  }

  static TextStyle textFontSize16FontWeightBold() {
    return const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  }

  static TextStyle textColorGrey() {
    return TextStyle(color: Colors.grey[700]);
  }

  static TextStyle textColorWhite() {
    return const TextStyle(color: Colors.white);
  }

  static TextStyle textFontSize18FontWeight600() {
    return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  }

  static TextStyle textFontSize24FontWeightBold() {
    return const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle textFontSize16() {
    return const TextStyle(fontSize: 16);
  }

  static TextStyle textFontSize20FontWeightBold() {
    return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle textColorBlueDecUnderline() {
    return const TextStyle(color: Colors.blue, decoration: TextDecoration.underline);
  }

  static EdgeInsets edgeInsetsAll8() {
    return const EdgeInsets.all(8.0);
  }

  static EdgeInsets edgeInsetsAll16() {
    return const EdgeInsets.all(16.0);
  }

  static EdgeInsets edgeInsetsOnlyRight16() {
    return const EdgeInsets.only(right: 16);
  }

  static EdgeInsets edgeInsetsSymV8H16() {
    return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
  }

  static EdgeInsets edgeInsetsSymV8() {
    return const EdgeInsets.symmetric(vertical: 8);
  }

  static ButtonStyle buttonStyleAdmin(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
    );
  }

  static SizedBox sizedBox4() {
    return const SizedBox(height: 4);
  }

  static SizedBox sizedBox8() {
    return const SizedBox(height: 8);
  }

  static SizedBox sizedBox16() {
    return const SizedBox(height: 16);
  }

  static SizedBox sizedBox24() {
    return const SizedBox(height: 24);
  }

  static OutlineInputBorder outlineInputBorder() {
    return  OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );
  }

  static CrossAxisAlignment crossAxisAlignmentStretch() {
    return CrossAxisAlignment.stretch;
  }

  static CrossAxisAlignment crossAxisAlignmentStart() {
    return CrossAxisAlignment.start;
  }

  static PopupProps<Map<UnitOfMeasure, String>> propsUnitOfMeasure() {
    return const PopupProps.menu(
      showSelectedItems: true,
    );
  }

  static PopupProps<ProductModel> propsProductModel() {
    return const PopupProps.menu(
      showSelectedItems: true,
      showSearchBox: true,
    );
  }

  static BorderRadius borderRadius8() {
    return BorderRadius.circular(8);
  }
}