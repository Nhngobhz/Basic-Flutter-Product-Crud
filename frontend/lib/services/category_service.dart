import 'api_service.dart';

class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CategoryService {
  static const _base = '/api/categories';

  // GET /categories?search=
  static Future<List<Category>> getAll({String search = ''}) async {
    final path = search.isEmpty
        ? _base
        : '$_base?search=${Uri.encodeComponent(search)}';
    final data = await ApiService.get(path);
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  // GET /categories/:id
  static Future<Category> getById(int id) async {
    final data = await ApiService.get('$_base/$id');
    return Category.fromJson(data);
  }

  // POST /categories
  static Future<void> create({required String name}) async {
    await ApiService.post(_base, {'name': name}, auth: true);
  }

  // PUT /categories/:id
  static Future<void> update({required int id, required String name}) async {
    await ApiService.put('$_base/$id', {'name': name});
  }

  // DELETE /categories/:id
  static Future<void> delete(int id) async {
    await ApiService.delete('$_base/$id');
  }
}
