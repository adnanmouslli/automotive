class Expenses {
  final double fuel;
  final double wash;
  final double adBlue;
  final double other;

  Expenses({
    required this.fuel,
    required this.wash,
    required this.adBlue,
    required this.other,
  });

  double get total => fuel + wash + adBlue + other;

  Map<String, dynamic> toJson() => {
    'fuel': fuel,
    'wash': wash,
    'adBlue': adBlue,
    'other': other,
  };

  factory Expenses.fromJson(Map<String, dynamic> json) => Expenses(
    fuel: (json['fuel'] ?? 0).toDouble(),
    wash: (json['wash'] ?? 0).toDouble(),
    adBlue: (json['adBlue'] ?? 0).toDouble(),
    other: (json['other'] ?? 0).toDouble(),
  );
}