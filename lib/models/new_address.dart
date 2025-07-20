class NewAddress {
  final String street;
  final String houseNumber;
  final String zipCode;
  final String city;
  final String country;

  final DateTime? date; // تاريخ الاستلام/التسليم
  final String? companyName; // اسم الشركة
  final String? contactPersonName; // اسم الموظف المختص
  final String? contactPersonPhone; // رقم هاتف الموظف
  final String? contactPersonEmail; // بريد الموظف
  final int? fuelLevel; // مستوى البنزين من 0 إلى 8
  final double? fuelMeter; // عداد البنزين

  NewAddress({
    required this.street,
    required this.houseNumber,
    required this.zipCode,
    required this.city,
    this.country = 'Deutschland',
    this.date,
    this.companyName,
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.fuelLevel,
    this.fuelMeter,
  });

  factory NewAddress.fromJson(Map<String, dynamic> json) {
    return NewAddress(
      street: json['street']?.toString() ?? '',
      houseNumber: json['houseNumber']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Deutschland',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      companyName: json['companyName']?.toString(),
      contactPersonName: json['contactPersonName']?.toString(),
      contactPersonPhone: json['contactPersonPhone']?.toString(),
      contactPersonEmail: json['contactPersonEmail']?.toString(),
      fuelLevel: json['fuelLevel'] is int ? json['fuelLevel'] : int.tryParse(json['fuelLevel']?.toString() ?? ''),
      fuelMeter: json['fuelMeter'] is double ? json['fuelMeter'] : double.tryParse(json['fuelMeter']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'houseNumber': houseNumber,
      'zipCode': zipCode,
      'city': city,
      'country': country,

      // ===== الحقول الجديدة =====
      'date': date?.toIso8601String(),
      'companyName': companyName,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'contactPersonEmail': contactPersonEmail,
      'fuelLevel': fuelLevel,
      'fuelMeter': fuelMeter,
    };
  }

  NewAddress copyWith({
    String? street,
    String? houseNumber,
    String? zipCode,
    String? city,
    String? country,
    DateTime? date,
    String? companyName,
    String? contactPersonName,
    String? contactPersonPhone,
    String? contactPersonEmail,
    int? fuelLevel,
    double? fuelMeter,
  }) {
    return NewAddress(
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      country: country ?? this.country,
      date: date ?? this.date,
      companyName: companyName ?? this.companyName,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      contactPersonEmail: contactPersonEmail ?? this.contactPersonEmail,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      fuelMeter: fuelMeter ?? this.fuelMeter,
    );
  }

  @override
  String toString() {
    return '$street $houseNumber, $zipCode $city, $country';
  }
}