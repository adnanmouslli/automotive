class NewAddress {
  final String street;
  final String houseNumber;
  final String zipCode;
  final String city;
  final String country;

  NewAddress({
    required this.street,
    required this.houseNumber,
    required this.zipCode,
    required this.city,
    this.country = 'Deutschland',
  });

  factory NewAddress.fromJson(Map<String, dynamic> json) {
    return NewAddress(
      street: json['street'] ?? '',
      houseNumber: json['houseNumber'] ?? '',
      zipCode: json['zipCode'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? 'Deutschland',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'houseNumber': houseNumber,
      'zipCode': zipCode,
      'city': city,
      'country': country,
    };
  }

  NewAddress copyWith({
    String? street,
    String? houseNumber,
    String? zipCode,
    String? city,
    String? country,
  }) {
    return NewAddress(
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}