class AppImage {
  final String name;
  final String imageUrl;

  AppImage({
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'imageUrl': imageUrl,
  };

  factory AppImage.fromJson(Map<String, dynamic> json) => AppImage(
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
  );
}