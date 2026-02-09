  import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product/';
  static const String _userAgent = 'YourAppName - Flutter - Version 1.0';

  Future<Map<String, dynamic>> fetchProductByBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$barcode.json'),
      headers: {'User-Agent': _userAgent},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        return _formatProductData(data['product'], barcode);
      }
      throw Exception('Product not found in database');
    } else {
      throw Exception('Failed to fetch product data');
    }
  }

  Map<String, dynamic> _formatProductData(Map<String, dynamic> product, String barcode) {
    return {
      'name': product['product_name'] ?? 'Unknown Product',
      'calories': product['nutriments']['energy-kcal_100g']?.toDouble() ?? 0.0,
      'protein': product['nutriments']['proteins_100g']?.toDouble() ?? 0.0,
      'carbs': product['nutriments']['carbohydrates_100g']?.toDouble() ?? 0.0,
      'fat': product['nutriments']['fat_100g']?.toDouble() ?? 0.0,
      'servingSize': product['serving_size'] ?? '100g',
      'imageUrl': product['image_front_url'],
      'barcode': barcode,
      'ingredients': (product['ingredients'] as List<dynamic>?)
          ?.map((i) => i['text'] as String?)
          .where((text) => text != null)
          .cast<String>()
          .toList() ?? [],
      'brand': product['brands'] ?? '',
    };
  }
}