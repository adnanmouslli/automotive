class Address {
  final String street;
  final String houseNumber;
  final String zipCode;
  final String city;

  Address({
    required this.street,
    required this.houseNumber,
    required this.zipCode,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
    'street': street,
    'houseNumber': houseNumber,
    'zipCode': zipCode,
    'city': city,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] ?? '',
    houseNumber: json['houseNumber'] ?? '',
    zipCode: json['zipCode'] ?? '',
    city: json['city'] ?? '',
  );

  @override
  String toString() => '$street $houseNumber, $zipCode $city';
}