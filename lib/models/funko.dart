class FunkoVariant {
  final String type;
  final bool isChase;

  FunkoVariant({
    required this.type,
    required this.isChase,
  });

  factory FunkoVariant.fromJson(Map<String, dynamic> json) {
    return FunkoVariant(
      type: json['type'] ?? 'standard',
      isChase: json['isChase'] ?? false,
    );
  }
}

class Funko {
  final String name;
  final int number;
  final String category;
  final String size;
  final String date;
  final List<FunkoVariant> variants;

  Funko({
    required this.name,
    required this.number,
    required this.category,
    required this.size,
    required this.date,
    required this.variants,
  });

  factory Funko.fromJson(Map<String, dynamic> json) {
    var variantsJson = json['variants'] as List? ?? [];
    List<FunkoVariant> variantList =
        variantsJson.map((v) => FunkoVariant.fromJson(v)).toList();

    return Funko(
      name: json['name'] ?? '',
      number: json['number'] ?? 0,
      category: json['category'] ?? 'Unknown',
      size: json['size'] ?? 'Regular',
      date: json['date'] ?? '',
      variants: variantList,
    );
  }
}