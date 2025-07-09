enum ServiceType { vehicleWash, registration, other }

class Service {
  final String vehicleType;
  final ServiceType serviceType;

  Service({
    required this.vehicleType,
    required this.serviceType,
  });

  Map<String, dynamic> toJson() => {
    'vehicleType': vehicleType,
    'serviceType': serviceType.name,
  };

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    vehicleType: json['vehicleType'] ?? '',
    serviceType: ServiceType.values.firstWhere(
          (e) => e.name == json['serviceType'],
      orElse: () => ServiceType.other,
    ),
  );
}