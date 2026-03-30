class FunkoVariant {
  final String name;
  final String type;
  final String image;
  final String series;
  final bool exclusive;
  final String? description;

  FunkoVariant({
    required this.name,
    required this.type,
    required this.image,
    required this.series,
    required this.exclusive,
    this.description,
  });

  factory FunkoVariant.fromJson(Map<String, dynamic> json) {
    return FunkoVariant(
      name: json['name'] ?? '',
      type: json['type'] ?? 'base',
      image: json['image'] ?? '',
      series: json['series'] ?? 'N/A', // Se manca nel JSON, mette N/A
      exclusive: json['exclusive'] ?? false, // Se manca nel JSON, mette false
      description: json['description'],
    );
  }
}

class Funko {
  final String name;
  final int number;
  final String saga;
  final String date;
  final List<FunkoVariant> variants;

  Funko({
    required this.name,
    required this.number,
    required this.saga,
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
      saga: json['saga'] ?? 'Unknown',
      date: json['date'] ?? '',
      variants: variantList,
    );
  }
}