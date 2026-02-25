// product_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final int? categoryId;
  final double price;
  final String? imageUrl; // the value returned by the API

  const Product({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    required this.price,
    this.imageUrl,
  });

  // helper to ensure the base URL is prepended if needed
  static String? _normalizeImageUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url; // already absolute
    return '${ApiService.baseUrl}$url'; // prepend base
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    categoryId: json['category_id'] as int?,
    price: double.parse(json['price'].toString()),
    imageUrl: _normalizeImageUrl(json['image_url'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category_id': categoryId,
    'price': price,
    'image_url': imageUrl, // send back as‑is
  };

  /// if you prefer to keep the raw `imageUrl` separate, you can expose a
  /// computed property instead:
  String? get fullImageUrl => _normalizeImageUrl(imageUrl);
}

class ProductService {
  static const _base = '/api/products';

  // GET /products?page=&limit=&search=&sortBy=
  static Future<List<Product>> getAll({
    int page = 1,
    int limit = 20,
    String search = '',
    String sortBy = 'name',
  }) async {
    final params = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search.isNotEmpty) 'search': search,
      'sortBy': sortBy,
    };
    final query = Uri(queryParameters: params).query;
    final data = await ApiService.get('$_base?$query');
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  // GET /products/:id
  static Future<Product> getById(int id) async {
    final data = await ApiService.get('$_base/$id');
    return Product.fromJson(data);
  }

  // POST /products  — multipart/form-data
  static Future<void> create({
    required String name,
    String? description,
    int? categoryId,
    required double price,
    File? imageFile,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}$_base');

    final request = http.MultipartRequest('POST', uri);

    // Headers
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // Fields
    request.fields['name'] = name;
    request.fields['price'] = price.toString();
    if (description != null) request.fields['description'] = description;
    if (categoryId != null) {
      request.fields['category_id'] = categoryId.toString();
    }
    // File
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // must match upload.single('image') in Express
          imageFile.path,
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    _handleResponse(response);
  }

  // PUT /products/:id  — multipart/form-data
  static Future<void> update({
    required int id,
    required String name,
    String? description,
    int? categoryId,
    required double price,
    File? imageFile,
    bool removeImage = false,
  }) async {
    final token = await ApiService.getToken();
    final uri = Uri.parse('${ApiService.baseUrl}$_base/$id');

    final request = http.MultipartRequest('PUT', uri);

    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['price'] = price.toString();
    if (description != null) request.fields['description'] = description;
    if (categoryId != null) {
      request.fields['category_id'] = categoryId.toString();
    }

    if (removeImage) request.fields['remove_image'] = 'true';

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    _handleResponse(response);
  }

  // DELETE /products/:id
  static Future<void> delete(int id) async {
    await ApiService.delete('$_base/$id');
  }

  static void _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final body = jsonDecode(response.body);
    final msg = body['message'] ?? body['error'] ?? 'Something went wrong';
    throw ApiException(msg, statusCode: response.statusCode);
  }
}
