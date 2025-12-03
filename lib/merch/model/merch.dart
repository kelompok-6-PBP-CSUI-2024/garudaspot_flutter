import 'dart:convert';

class Merch {
  const Merch({
    required this.id,
    required this.name,
    required this.vendor,
    required this.price,
    required this.stock,
    required this.description,
    required this.thumbnail,
    required this.category,
    required this.link,
  });

  final int id;
  final String name;
  final String vendor;
  final int price;
  final int stock;
  final String description;
  final String thumbnail;
  final String category;
  final String link;

  factory Merch.fromJson(Map<String, dynamic> json) {
    return Merch(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      vendor: json['vendor']?.toString() ?? '',
      price: _toInt(json['price']),
      stock: _toInt(json['stock']),
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vendor': vendor,
      'price': price,
      'stock': stock,
      'description': description,
      'thumbnail': thumbnail,
      'category': category,
      'link': link,
    };
  }
}

List<Merch> merchListFromJson(String str) {
  final dynamic data = json.decode(str);
  if (data is List) {
    return data.map((e) => Merch.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
