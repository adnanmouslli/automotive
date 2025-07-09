class AppSignature {
  final String name;
  final DateTime time;
  final String signatureUrl;

  AppSignature({
    required this.name,
    required this.time,
    required this.signatureUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time.toIso8601String(),
    'signatureUrl': signatureUrl,
  };

  factory AppSignature.fromJson(Map<String, dynamic> json) => AppSignature(
    name: json['name'] ?? '',
    time: DateTime.parse(json['time']),
    signatureUrl: json['signatureUrl'] ?? '',
  );
}
