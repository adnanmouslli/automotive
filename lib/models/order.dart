import 'dart:developer';

import 'package:automotive/models/signature.dart';
import 'package:automotive/models/vehicle_data.dart';

import 'address.dart';
import 'app_image.dart';
import 'expenses.dart';
import 'loading_date.dart';
import 'service.dart';

class Order {
  final String id;
  final int orderNumber;
  final String client;
  final Address clientAddress;
  final String invoiceRecipient;
  final Address invoiceRecipientAddress;
  final VehicleData vehicleData;
  final Service service;
  final LoadingDate pickup;
  final LoadingDate delivery;
  final String acceptanceRequirement;
  final int routeStart;
  final int routeEnd;
  final Expenses expenses;
  final int waitingTime;
  final String comments;
  final AppSignature? driverSignature;
  final AppSignature? customerSignature;
  final List<String> items;
  final String status;
  final String result;
  final List<AppImage> pickupImages;
  final List<AppImage> deliveryImages;
  final List<AppImage> additionalImages;
  final String driverId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.client,
    required this.clientAddress,
    required this.invoiceRecipient,
    required this.invoiceRecipientAddress,
    required this.vehicleData,
    required this.service,
    required this.pickup,
    required this.delivery,
    required this.acceptanceRequirement,
    required this.routeStart,
    required this.routeEnd,
    required this.expenses,
    required this.waitingTime,
    required this.comments,
    this.driverSignature,
    this.customerSignature,
    required this.items,
    required this.status,
    required this.result,
    required this.pickupImages,
    required this.deliveryImages,
    required this.additionalImages,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'client': client,
    'clientAddress': clientAddress.toJson(),
    'invoiceRecipient': invoiceRecipient,
    'invoiceRecipientAddress': invoiceRecipientAddress.toJson(),
    'vehicleData': vehicleData.toJson(),
    'service': service.toJson(),
    'pickup': pickup.toJson(),
    'delivery': delivery.toJson(),
    'acceptanceRequirement': acceptanceRequirement,
    'routeStart': routeStart,
    'routeEnd': routeEnd,
    'expenses': expenses.toJson(),
    'waitingTime': waitingTime,
    'comments': comments,
    'driverSignature': driverSignature?.toJson(),
    'customerSignature': customerSignature?.toJson(),
    'items': items,
    'status': status,
    'result': result,
    'pickupImages': pickupImages.map((e) => e.toJson()).toList(),
    'deliveryImages': deliveryImages.map((e) => e.toJson()).toList(),
    'additionalImages': additionalImages.map((e) => e.toJson()).toList(),
    'driverId': driverId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] ?? '',
    orderNumber: json['orderNumber'] ?? 0,
    client: json['client'] ?? '',
    clientAddress: Address.fromJson(json['clientAddress'] ?? {}),
    invoiceRecipient: json['invoiceRecipient'] ?? '',
    invoiceRecipientAddress: Address.fromJson(json['invoiceRecipientAddress'] ?? {}),
    vehicleData: VehicleData.fromJson(json['vehicleData'] ?? {}),
    service: Service.fromJson(json['service'] ?? {}),
    pickup: LoadingDate.fromJson(json['pickup'] ?? {}),
    delivery: LoadingDate.fromJson(json['delivery'] ?? {}),
    acceptanceRequirement: json['acceptanceRequirement'] ?? '',
    routeStart: json['routeStart'] ?? 0,
    routeEnd: json['routeEnd'] ?? 0,
    expenses: Expenses.fromJson(json['expenses'] ?? {}),
    waitingTime: json['waitingTime'] ?? 0,
    comments: json['comments'] ?? '',
    driverSignature: json['driverSignature'] != null
        ? AppSignature.fromJson(json['driverSignature'])
        : null,
    customerSignature: json['customerSignature'] != null
        ? AppSignature.fromJson(json['customerSignature'])
        : null,
    items: List<String>.from(json['items'] ?? []),
    status: json['status'] ?? 'pending',
    result: json['result'] ?? '',
    pickupImages: (json['pickupImages'] as List?)
        ?.map((e) => AppImage.fromJson(e))
        .toList() ?? [],
    deliveryImages: (json['deliveryImages'] as List?)
        ?.map((e) => AppImage.fromJson(e))
        .toList() ?? [],
    additionalImages: (json['additionalImages'] as List?)
        ?.map((e) => AppImage.fromJson(e))
        .toList() ?? [],
    driverId: json['driverId'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  Order copyWith({
    String? id,
    int? orderNumber,
    String? client,
    Address? clientAddress,
    String? invoiceRecipient,
    Address? invoiceRecipientAddress,
    VehicleData? vehicleData,
    Service? service,
    LoadingDate? pickup,
    LoadingDate? delivery,
    String? acceptanceRequirement,
    int? routeStart,
    int? routeEnd,
    Expenses? expenses,
    int? waitingTime,
    String? comments,
    AppSignature? driverSignature,
    AppSignature? customerSignature,
    List<String>? items,
    String? status,
    String? result,
    List<AppImage>? pickupImages,
    List<AppImage>? deliveryImages,
    List<AppImage>? additionalImages,
    String? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      client: client ?? this.client,
      clientAddress: clientAddress ?? this.clientAddress,
      invoiceRecipient: invoiceRecipient ?? this.invoiceRecipient,
      invoiceRecipientAddress: invoiceRecipientAddress ?? this.invoiceRecipientAddress,
      vehicleData: vehicleData ?? this.vehicleData,
      service: service ?? this.service,
      pickup: pickup ?? this.pickup,
      delivery: delivery ?? this.delivery,
      acceptanceRequirement: acceptanceRequirement ?? this.acceptanceRequirement,
      routeStart: routeStart ?? this.routeStart,
      routeEnd: routeEnd ?? this.routeEnd,
      expenses: expenses ?? this.expenses,
      waitingTime: waitingTime ?? this.waitingTime,
      comments: comments ?? this.comments,
      driverSignature: driverSignature ?? this.driverSignature,
      customerSignature: customerSignature ?? this.customerSignature,
      items: items ?? this.items,
      status: status ?? this.status,
      result: result ?? this.result,
      pickupImages: pickupImages ?? this.pickupImages,
      deliveryImages: deliveryImages ?? this.deliveryImages,
      additionalImages: additionalImages ?? this.additionalImages,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}