import 'api_service.dart';

class Category {
  final int id;
  final String name;
  final String? description;

  const Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}

class CategoryService {
  static const _base = '/api/categories';

  static Future<List<Category>> getAll({String search = ''}) async {
    final path = search.isEmpty
        ? _base
        : '$_base?search=${Uri.encodeComponent(search)}';
    final data = await ApiService.get(path);
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  static Future<Category> getById(int id) async {
    final data = await ApiService.get('$_base/$id');
    return Category.fromJson(data);
  }

  static Future<void> create({
    required String name,
    String? description,
  }) async {
    await ApiService.post(_base, {
      'name': name,
      'description': description,
    }, auth: true);
  }

  static Future<void> update({
    required int id,
    required String name,
    String? description,
  }) async {
    await ApiService.put('$_base/$id', {
      'name': name,
      'description': description,
    });
  }

  static Future<void> delete(int id) async {
    await ApiService.delete('$_base/$id');
  }
}
