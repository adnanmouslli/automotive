class VehicleData {
  final String vehicleOwner;
  final String licensePlate;
  final String ukz;
  final String vin;
  final int orderNumber;
  final int leasingContractNumber;
  final String costCenter;
  final String remarks;

  VehicleData({
    required this.vehicleOwner,
    required this.licensePlate,
    required this.ukz,
    required this.vin,
    required this.orderNumber,
    required this.leasingContractNumber,
    required this.costCenter,
    required this.remarks,
  });

  Map<String, dynamic> toJson() => {
    'vehicleOwner': vehicleOwner,
    'licensePlate': licensePlate,
    'ukz': ukz,
    'vin': vin,
    'orderNumber': orderNumber,
    'leasingContractNumber': leasingContractNumber,
    'costCenter': costCenter,
    'remarks': remarks,
  };

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
    vehicleOwner: json['vehicleOwner'] ?? '',
    licensePlate: json['licensePlate'] ?? '',
    ukz: json['ukz'] ?? '',
    vin: json['vin'] ?? '',
    orderNumber: json['orderNumber'] ?? 0,
    leasingContractNumber: json['leasingContractNumber'] ?? 0,
    costCenter: json['costCenter'] ?? '',
    remarks: json['remarks'] ?? '',
  );
}