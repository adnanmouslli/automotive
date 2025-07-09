import 'address.dart';

class LoadingDate {
  final DateTime time;
  final String company;
  final Address address;
  final String contactPerson;
  final String phone;
  final String email;
  final int loadingStatus; // 1-8

  LoadingDate({
    required this.time,
    required this.company,
    required this.address,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.loadingStatus,
  });

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'company': company,
    'address': address.toJson(),
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'loadingStatus': loadingStatus,
  };

  factory LoadingDate.fromJson(Map<String, dynamic> json) => LoadingDate(
    time: DateTime.parse(json['time']),
    company: json['company'] ?? '',
    address: Address.fromJson(json['address'] ?? {}),
    contactPerson: json['contactPerson'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    loadingStatus: json['loadingStatus'] ?? 1,
  );
}