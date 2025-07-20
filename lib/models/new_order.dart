import 'new_address.dart';

enum ServiceType {
  WASH,      // غسيل السيارة
  REGISTRATION,      // تسجيل
  TRANSPORT,         // نقل
  INSPECTION,        // فحص
  MAINTENANCE        // صيانة
}

enum ImageCategory { PICKUP, DELIVERY, ADDITIONAL, DAMAGE, INTERIOR, EXTERIOR }

class OrderImage {
  final String id;
  final String imageUrl;
  final ImageCategory category;
  final String description;
  final DateTime uploadedAt;

  OrderImage({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.uploadedAt,
  });

  factory OrderImage.fromJson(Map<String, dynamic> json) {
    return OrderImage(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: ImageCategory.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (json['category']?.toString().toLowerCase() ?? 'additional'),
        orElse: () => ImageCategory.ADDITIONAL,
      ),
      description: json['description']?.toString() ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last.toUpperCase(),
      'description': description,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class OrderSignature {
  final String id;
  final String signatureUrl;
  final String name;
  final bool isDriver;
  final DateTime signedAt;

  OrderSignature({
    required this.id,
    required this.signatureUrl,
    required this.name,
    required this.isDriver,
    required this.signedAt,
  });

  factory OrderSignature.fromJson(Map<String, dynamic> json) {
    return OrderSignature(
      id: json['id']?.toString() ?? '',
      signatureUrl: json['signatureUrl']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isDriver: json['isDriver'] == true ||
          json['isDriver']?.toString().toLowerCase() == 'true',
      signedAt: json['signedAt'] != null
          ? DateTime.parse(json['signedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signatureUrl': signatureUrl,
      'name': name,
      'isDriver': isDriver,
      'signedAt': signedAt.toIso8601String(),
    };
  }
}

class OrderExpenses {
  final double fuel;
  final double wash;
  final double adBlue;
  final double other;
  final double tollFees;
  final double parking;
  final String notes;

  // حساب المجموع من جميع الحقول
  double get total => fuel + wash + adBlue + other + tollFees + parking;

  OrderExpenses({
    required this.fuel,
    required this.wash,
    required this.adBlue,
    required this.other,
    required this.tollFees,
    required this.parking,
    required this.notes,
  });

  factory OrderExpenses.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 تحليل بيانات المصروفات: $json');

      // دالة مساعدة للتحويل الآمن
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      // معالجة جميع الحقول
      double safeFuel = parseDouble(json['fuel']);
      double safeWash = parseDouble(json['wash']);
      double safeAdBlue = parseDouble(json['adBlue']);
      double safeOther = parseDouble(json['other']);
      double safeTollFees = parseDouble(json['tollFees']);
      double safeParking = parseDouble(json['parking']);
      String safeNotes = json['notes']?.toString() ?? '';

      print('✅ المصروفات المحللة:');
      print('   وقود: $safeFuel');
      print('   غسيل: $safeWash');
      print('   AdBlue: $safeAdBlue');
      print('   أخرى: $safeOther');
      print('   رسوم الطريق: $safeTollFees');
      print('   مواقف السيارات: $safeParking');

      return OrderExpenses(
        fuel: safeFuel,
        wash: safeWash,
        adBlue: safeAdBlue,
        other: safeOther,
        tollFees: safeTollFees,
        parking: safeParking,
        notes: safeNotes,
      );
    } catch (e) {
      print('❌ خطأ في تحليل بيانات المصروفات: $e');
      print('📄 البيانات الأصلية: $json');

      // إرجاع قيم افتراضية في حالة الخطأ
      return OrderExpenses(
        fuel: 0.0,
        wash: 0.0,
        adBlue: 0.0,
        other: 0.0,
        tollFees: 0.0,
        parking: 0.0,
        notes: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'fuel': fuel,
      'wash': wash,
      'adBlue': adBlue,
      'other': other,
      'tollFees': tollFees,
      'parking': parking,
      'notes': notes,
    };
  }
}


// إضافة enum للأغراض
enum VehicleItem {
  PARTITION_NET,      // شبكة التقسيم
  WINTER_TIRES,       // إطارات شتوية
  HUBCAPS,           // أغطية العجل
  REAR_PARCEL_SHELF,  // رف الطرود الخلفي
  NAVIGATION_SYSTEM,  // نظام الملاحة
  TRUNK_ROLL_COVER,   // غطاء صندوق السيارة
  SAFETY_VEST,        // سترة الأمان
  VEHICLE_KEYS,       // مفاتيح السيارة
  WARNING_TRIANGLE,   // مثلث التحذير
  RADIO,             // راديو
  ALLOY_WHEELS,      // عجلات سبيكة
  SUMMER_TIRES,      // إطارات صيفية
  OPERATING_MANUAL,   // دليل التشغيل
  REGISTRATION_DOCUMENT, // وثيقة التسجيل
  COMPRESSOR_REPAIR_KIT, // طقم الضاغط/الإصلاح
  TOOLS_JACK,        // الأدوات/الجاك
  SECOND_SET_OF_TIRES, // مجموعة ثانية من الإطارات
  EMERGENCY_WHEEL,    // عجلة الطوارئ
  ANTENNA,           // الهوائي
  FUEL_CARD,         // بطاقة الوقود
  FIRST_AID_KIT,     // طقم الإسعافات الأولية
  SPARE_TIRE,        // الإطار الاحتياطي
  SERVICE_BOOK       // كتاب الخدمة
}

class NewOrder {
  final String id;
  final String client;
  final String clientPhone;
  final String clientEmail;
  final NewAddress? clientAddress;

  // بيانات صاحب الفاتورة الجديدة
  final bool isSameBilling; // جديد - هل نفس العميل؟
  final String? billingName; // جديد - اسم صاحب الفاتورة
  final String? billingPhone; // جديد - هاتف صاحب الفاتورة
  final String? billingEmail; // جديد - بريد صاحب الفاتورة
  final NewAddress? billingAddress; // جديد - عنوان صاحب الفاتورة


  final String description;
  final String comments;
  final List<VehicleItem> items;
  final String vehicleOwner;
  final String licensePlateNumber;
  final String vin;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String vehicleType;

  final String ukz;                    // ÜKZ
  final String fin;                    // FIN
  final String bestellnummer;          // Bestellnummer
  final String leasingvertragsnummer;  // Leasingvertragsnummer
  final String kostenstelle;          // Kostenstelle
  final String bemerkung;              // Bemerkung
  final String typ;                    // Typ

  final ServiceType serviceType;
  final String serviceDescription;
  final NewAddress pickupAddress;
  final NewAddress deliveryAddress;
  final List<OrderImage> images;
  final List<OrderSignature> signatures;
  final OrderExpenses? expenses;
  final String status;
  final String driverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? orderNumber; // إضافة رقم الطلبية من الباك إند

  final List<VehicleDamage> damages;

  NewOrder({
    required this.id,
    required this.client,
    required this.clientPhone,
    required this.clientEmail,

    this.clientAddress,
    this.isSameBilling = true, // جديد - افتراضياً true
    this.billingName, // جديد
    this.billingPhone, // جديد
    this.billingEmail, // جديد
    this.billingAddress, // جديد

    required this.description,
    this.comments = '',
    this.items = const [],
    required this.vehicleOwner,
    required this.licensePlateNumber,
    this.vin = '',
    this.brand = '',
    this.model = '',
    this.year = 0,
    this.color = '',
    this.vehicleType = '',
    this.ukz = '',
    this.fin = '',
    this.bestellnummer = '',
    this.leasingvertragsnummer = '',
    this.kostenstelle = '',
    this.bemerkung = '',
    this.typ = '',

    this.serviceType = ServiceType.TRANSPORT,
    this.serviceDescription = '',
    required this.pickupAddress,
    required this.deliveryAddress,
    this.images = const [],
    this.signatures = const [],
    this.expenses,
    this.status = 'pending',
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    this.orderNumber,

    this.damages = const [],

  });

  // Computed properties
  bool get hasDriverSignature => signatures.any((s) => s.isDriver);
  bool get hasCustomerSignature => signatures.any((s) => !s.isDriver);
  bool get hasAllSignatures => hasDriverSignature && hasCustomerSignature;
  bool get hasImages => images.isNotEmpty;
  bool get hasExpenses => expenses != null;
  bool get isCompleted => status == 'completed';

  OrderSignature? get driverSignature =>
      signatures.where((s) => s.isDriver).isNotEmpty
          ? signatures.firstWhere((s) => s.isDriver)
          : null;

  OrderSignature? get customerSignature =>
      signatures.where((s) => !s.isDriver).isNotEmpty
          ? signatures.firstWhere((s) => !s.isDriver)
          : null;

  factory NewOrder.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 تحليل بيانات الطلبية: ${json.keys.join(', ')}');

      // استخراج البيانات من الهياكل المختلفة
      final vehicleData = json['vehicleData'] as Map<String, dynamic>?;
      final serviceData = json['service'] as Map<String, dynamic>?;
      final driver = json['driver'] as Map<String, dynamic>?;

      // تحليل التوقيعات بطريقة مرنة
      final signatures = _parseSignaturesFlexible(json);
      print('📝 عدد التوقيعات المُحللة: ${signatures.length}');

      // تحليل الصور
      final images = _parseImages(json['images']);
      print('📸 عدد الصور المُحللة: ${images.length}');

      // تحليل المصاريف
      OrderExpenses? expenses;
      if (json['expenses'] != null) {
        try {
          expenses = OrderExpenses.fromJson(json['expenses'] as Map<String, dynamic>);
          print('💰 تم تحليل المصاريف: ${expenses.total}');
        } catch (e) {
          print('⚠️ خطأ في تحليل المصاريف: $e');
        }
      }

      // تحليل عنوان العميل
      NewAddress? clientAddress;
      if (json['clientAddress'] != null) {
        if (json['clientAddress'] is Map<String, dynamic>) {
          clientAddress = _parseAddressSafely(json['clientAddress']);
        } else if (json['clientAddress'] is String) {
          clientAddress = NewAddress(
            street: json['clientAddress'].toString(),
            houseNumber: '',
            zipCode: '',
            city: '',
          );
        }
      }

      // تحليل عنوان صاحب الفاتورة
      NewAddress? billingAddress;
      if (json['billingAddress'] != null) {
        if (json['billingAddress'] is Map<String, dynamic>) {
          billingAddress = _parseAddressSafely(json['billingAddress']);
        } else if (json['billingAddress'] is String) {
          billingAddress = NewAddress(
            street: json['billingAddress'].toString(),
            houseNumber: '',
            zipCode: '',
            city: '',
          );
        }
      }

      // تحليل الحالة بمرونة
      String status = 'pending';
      if (json['status'] != null) {
        status = json['status'].toString().toLowerCase();
        if (!['pending', 'in_progress', 'completed', 'cancelled'].contains(status)) {
          print('⚠️ حالة غير معروفة: ${json['status']}, سيتم استخدام pending');
          status = 'pending';
        }
      }

      final newOrder = NewOrder(
        id: json['id']?.toString() ?? '',
        orderNumber: json['orderNumber']?.toString(),
        client: json['client']?.toString() ?? '',
        clientPhone: json['clientPhone']?.toString() ?? '',
        clientEmail: json['clientEmail']?.toString() ?? '',

        clientAddress: clientAddress,
        isSameBilling: json['isSameBilling'] ?? true,
        billingName: json['billingName'],
        billingPhone: json['billingPhone'],
        billingEmail: json['billingEmail'],
        billingAddress: billingAddress,

        description: json['description']?.toString() ?? '',
        comments: json['comments']?.toString() ?? '',

        // تحليل الأغراض مع التحويل الآمن
        items: _parseVehicleItems(json['items']),

        // بيانات المركبة مع معالجة القيم الفارغة
        vehicleOwner: vehicleData?['vehicleOwner']?.toString() ??
            json['vehicleOwner']?.toString() ?? '',
        licensePlateNumber: vehicleData?['licensePlateNumber']?.toString() ??
            json['licensePlateNumber']?.toString() ?? '',
        vin: vehicleData?['vin']?.toString() ??
            json['vin']?.toString() ?? '',
        brand: vehicleData?['brand']?.toString() ??
            json['brand']?.toString() ?? '',
        model: vehicleData?['model']?.toString() ??
            json['model']?.toString() ?? '',
        year: _parseIntSafely(vehicleData?['year']) ??
            _parseIntSafely(json['year']) ?? 0,
        color: vehicleData?['color']?.toString() ??
            json['color']?.toString() ?? '',

        ukz: vehicleData?['ukz']?.toString() ??
            json['ukz']?.toString() ?? '',
        fin: vehicleData?['fin']?.toString() ??
            json['fin']?.toString() ?? '',
        bestellnummer: vehicleData?['bestellnummer']?.toString() ??
            json['bestellnummer']?.toString() ?? '',
        leasingvertragsnummer: vehicleData?['leasingvertragsnummer']?.toString() ??
            json['leasingvertragsnummer']?.toString() ?? '',
        kostenstelle: vehicleData?['kostenstelle']?.toString() ??
            json['kostenstelle']?.toString() ?? '',
        bemerkung: vehicleData?['bemerkung']?.toString() ??
            json['bemerkung']?.toString() ?? '',
        typ: vehicleData?['typ']?.toString() ??
            json['typ']?.toString() ?? '',

        // بيانات الخدمة
        vehicleType: serviceData?['vehicleType']?.toString() ??
            json['vehicleType']?.toString() ?? '',
        serviceType: _parseServiceTypeSafely(serviceData?['serviceType']) ??
            _parseServiceTypeSafely(json['serviceType']) ??
            ServiceType.TRANSPORT,
        serviceDescription: serviceData?['description']?.toString() ??
            json['serviceDescription']?.toString() ?? '',

        // العناوين مع معالجة الأخطاء
        pickupAddress: _parseAddressSafely(json['pickupAddress']),
        deliveryAddress: _parseAddressSafely(json['deliveryAddress']),

        // الملفات والتوقيعات
        images: images,
        signatures: signatures,
        expenses: expenses,

        // الحالة والمعرفات
        status: status,
        driverId: json['driverId']?.toString() ??
            driver?['id']?.toString() ?? '',

        damages: _parseVehicleDamages(json['damages']),

        // التواريخ مع معالجة الأخطاء
        createdAt: _parseDateSafely(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateSafely(json['updatedAt']) ?? DateTime.now(),
      );

      print('✅ تم تحليل الطلبية بنجاح: ${newOrder.client} (${newOrder.status})');
      return newOrder;

    } catch (e, stackTrace) {
      print('❌ خطأ في تحليل بيانات الطلبية: $e');
      print('📄 البيانات الأصلية: $json');
      print('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // دالة جديدة لتحليل الأغراض
  static List<VehicleItem> _parseVehicleItems(dynamic value) {
    if (value == null || value is! List) return [];

    final List<VehicleItem> parsedItems = [];

    for (final item in value as List) {
      try {
        if (item is String) {
          // تحليل من String
          final itemString = item.toUpperCase();
          final vehicleItem = VehicleItem.values.firstWhere(
                (e) => e.toString().split('.').last == itemString,
            orElse: () => throw Exception('Invalid item: $itemString'),
          );
          parsedItems.add(vehicleItem);
        } else if (item is VehicleItem) {
          // إذا كان من نوع VehicleItem بالفعل
          parsedItems.add(item);
        } else {
          print('⚠️ نوع غرض غير معروف: ${item.runtimeType} - $item');
        }
      } catch (e) {
        print('⚠️ تجاهل غرض غير صحيح: $item - خطأ: $e');
      }
    }

    print('📦 تم تحليل ${parsedItems.length} غرض من أصل ${(value as List).length}');
    return parsedItems;
  }


  // دوال مساعدة محسنة للتحليل الآمن

  static List<OrderSignature> _parseSignaturesFlexible(Map<String, dynamic> json) {
    final signatures = <OrderSignature>[];

    try {
      // التوقيعات من حقل signatures إذا كان موجود
      if (json['signatures'] is List) {
        for (final sig in json['signatures'] as List) {
          try {
            if (sig is Map<String, dynamic>) {
              signatures.add(OrderSignature.fromJson(sig));
            }
          } catch (e) {
            print('⚠️ تجاهل توقيع غير صحيح: $e');
          }
        }
      }

      // التوقيعات المنفصلة من الباك إند
      if (json['driverSignature'] != null && json['driverSignature'] is Map) {
        try {
          final driverSig = json['driverSignature'] as Map<String, dynamic>;
          driverSig['isDriver'] = true; // تأكيد أنه توقيع سائق
          signatures.add(OrderSignature.fromJson(driverSig));
        } catch (e) {
          print('⚠️ خطأ في تحليل توقيع السائق: $e');
        }
      }

      if (json['customerSignature'] != null && json['customerSignature'] is Map) {
        try {
          final customerSig = json['customerSignature'] as Map<String, dynamic>;
          customerSig['isDriver'] = false; // تأكيد أنه توقيع عميل
          signatures.add(OrderSignature.fromJson(customerSig));
        } catch (e) {
          print('⚠️ خطأ في تحليل توقيع العميل: $e');
        }
      }

    } catch (e) {
      print('⚠️ خطأ عام في تحليل التوقيعات: $e');
    }

    return signatures;
  }

  static NewAddress _parseAddressSafely(dynamic addressData) {
    if (addressData == null || addressData is! Map<String, dynamic>) {
      return NewAddress(street: '', houseNumber: '', zipCode: '', city: '');
    }

    try {
      return NewAddress.fromJson(addressData);
    } catch (e) {
      print('⚠️ خطأ في تحليل العنوان: $e');
      return NewAddress(street: '', houseNumber: '', zipCode: '', city: '');
    }
  }

  static ServiceType? _parseServiceTypeSafely(dynamic value) {
    if (value == null) return null;

    try {
      final typeString = value.toString().toUpperCase();
      return ServiceType.values.firstWhere(
            (e) => e.toString().split('.').last == typeString,
        orElse: () => ServiceType.TRANSPORT,
      );
    } catch (e) {
      print('⚠️ خطأ في تحليل نوع الخدمة: $e');
      return ServiceType.TRANSPORT;
    }
  }

  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateSafely(dynamic value) {
    if (value == null) return null;

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      print('⚠️ خطأ في تحليل التاريخ: $e');
    }

    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    return [];
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static ServiceType _parseServiceType(dynamic value) {
    if (value == null) return ServiceType.TRANSPORT;

    final typeString = value.toString().toUpperCase();
    return ServiceType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => ServiceType.TRANSPORT,
    );
  }

  static List<OrderImage> _parseImages(dynamic value) {
    if (value == null || value is! List) return [];

    return (value as List)
        .map((img) {
          try {
            return OrderImage.fromJson(img as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing image: $e');
            return null;
          }
        })
        .where((img) => img != null)
        .cast<OrderImage>()
        .toList();
  }

  static List<OrderSignature> _parseSignatures(Map<String, dynamic> json) {
    final signatures = <OrderSignature>[];

    // التوقيعات من حقل signatures إذا كان موجود
    if (json['signatures'] is List) {
      for (final sig in json['signatures'] as List) {
        try {
          signatures.add(OrderSignature.fromJson(sig as Map<String, dynamic>));
        } catch (e) {
          print('Error parsing signature: $e');
        }
      }
    }

    // التوقيعات المنفصلة من الباك إند
    if (json['driverSignature'] != null) {
      try {
        signatures.add(OrderSignature.fromJson(
            json['driverSignature'] as Map<String, dynamic>));
      } catch (e) {
        print('Error parsing driver signature: $e');
      }
    }

    if (json['customerSignature'] != null) {
      try {
        signatures.add(OrderSignature.fromJson(
            json['customerSignature'] as Map<String, dynamic>));
      } catch (e) {
        print('Error parsing customer signature: $e');
      }
    }

    return signatures;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'client': client,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'clientAddress': clientAddress?.toJson(), // تم التغيير
      'isSameBilling': isSameBilling, // جديد
      'billingName': billingName, // جديد
      'billingPhone': billingPhone, // جديد
      'billingEmail': billingEmail, // جديد
      'billingAddress': billingAddress?.toJson(), // تم التغيير
      'description': description,
      'comments': comments,
      'items': items.map((item) => item.toString().split('.').last).toList(),

      'vehicleOwner': vehicleOwner,
      'licensePlateNumber': licensePlateNumber,
      'vin': vin,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,

      'ukz': ukz,
      'fin': fin,
      'bestellnummer': bestellnummer,
      'leasingvertragsnummer': leasingvertragsnummer,
      'kostenstelle': kostenstelle,
      'bemerkung': bemerkung,
      'typ': typ,

      'vehicleType': vehicleType,
      'serviceType': serviceType.toString().split('.').last,
      'serviceDescription': serviceDescription,
      'pickupAddress': pickupAddress.toJson(),
      'deliveryAddress': deliveryAddress.toJson(),
      'status': status,
      'driverId': driverId,
      'images': images.map((img) => img.toJson()).toList(),
      'signatures': signatures.map((sig) => sig.toJson()).toList(),
      'expenses': expenses?.toJson(),

      'damages': damages.map((damage) => damage.toJson()).toList(),

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NewOrder copyWith({
    String? id,
    String? client,
    String? clientPhone,
    String? clientEmail,
    NewAddress? clientAddress, // تم التغيير
    bool? isSameBilling, // جديد
    String? billingName, // جديد
    String? billingPhone, // جديد
    String? billingEmail, // جديد
    NewAddress? billingAddress, // تم التغيير

    String? description,
    String? comments,
    List<VehicleItem>? items,
    String? vehicleOwner,
    String? licensePlateNumber,
    String? vin,
    String? brand,
    String? model,
    int? year,
    String? color,

    String? ukz,
    String? fin,
    String? bestellnummer,
    String? leasingvertragsnummer,
    String? kostenstelle,
    String? bemerkung,
    String? typ,

    String? vehicleType,
    ServiceType? serviceType,
    String? serviceDescription,
    NewAddress? pickupAddress,
    NewAddress? deliveryAddress,
    List<OrderImage>? images,
    List<OrderSignature>? signatures,
    OrderExpenses? expenses,
    String? status,
    String? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? orderNumber,

    List<VehicleDamage>? damages,

  }) {
    return NewOrder(
      id: id ?? this.id,
      client: client ?? this.client,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress, // تم التغيير
      isSameBilling: isSameBilling ?? this.isSameBilling, // جديد
      billingName: billingName ?? this.billingName, // جديد
      billingPhone: billingPhone ?? this.billingPhone, // جديد
      billingEmail: billingEmail ?? this.billingEmail, // جديد
      billingAddress: billingAddress ?? this.billingAddress, // تم التغيير

      description: description ?? this.description,
      comments: comments ?? this.comments,
      items: items ?? this.items,
      vehicleOwner: vehicleOwner ?? this.vehicleOwner,
      licensePlateNumber: licensePlateNumber ?? this.licensePlateNumber,
      vin: vin ?? this.vin,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,

      ukz: ukz ?? this.ukz,
      fin: fin ?? this.fin,
      bestellnummer: bestellnummer ?? this.bestellnummer,
      leasingvertragsnummer: leasingvertragsnummer ?? this.leasingvertragsnummer,
      kostenstelle: kostenstelle ?? this.kostenstelle,
      bemerkung: bemerkung ?? this.bemerkung,
      typ: typ ?? this.typ,

      vehicleType: vehicleType ?? this.vehicleType,
      serviceType: serviceType ?? this.serviceType,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      images: images ?? this.images,
      signatures: signatures ?? this.signatures,
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderNumber: orderNumber ?? this.orderNumber,
      damages: damages ?? this.damages,

    );
  }

  // دالة helper جديدة لتحليل الأضرار
  static List<VehicleDamage> _parseVehicleDamages(dynamic value) {
    if (value == null || value is! List) return [];

    final List<VehicleDamage> parsedDamages = [];

    for (final damage in value as List) {
      try {
        if (damage is Map<String, dynamic>) {
          parsedDamages.add(VehicleDamage.fromJson(damage));
        }
      } catch (e) {
        print('⚠️ تجاهل ضرر غير صحيح: $damage - خطأ: $e');
      }
    }

    return parsedDamages;
  }

  // دالة مساعدة للحصول على نص الغرض بالعربية
  String getVehicleItemText(VehicleItem item) {
    switch (item) {
      case VehicleItem.PARTITION_NET:
        return 'شبكة التقسيم';
      case VehicleItem.WINTER_TIRES:
        return 'إطارات شتوية';
      case VehicleItem.HUBCAPS:
        return 'أغطية العجل';
      case VehicleItem.REAR_PARCEL_SHELF:
        return 'رف الطرود الخلفي';
      case VehicleItem.NAVIGATION_SYSTEM:
        return 'نظام الملاحة';
      case VehicleItem.TRUNK_ROLL_COVER:
        return 'غطاء صندوق السيارة';
      case VehicleItem.SAFETY_VEST:
        return 'سترة الأمان';
      case VehicleItem.VEHICLE_KEYS:
        return 'مفاتيح السيارة';
      case VehicleItem.WARNING_TRIANGLE:
        return 'مثلث التحذير';
      case VehicleItem.RADIO:
        return 'راديو';
      case VehicleItem.ALLOY_WHEELS:
        return 'عجلات سبيكة';
      case VehicleItem.SUMMER_TIRES:
        return 'إطارات صيفية';
      case VehicleItem.OPERATING_MANUAL:
        return 'دليل التشغيل';
      case VehicleItem.REGISTRATION_DOCUMENT:
        return 'وثيقة التسجيل';
      case VehicleItem.COMPRESSOR_REPAIR_KIT:
        return 'طقم الضاغط/الإصلاح';
      case VehicleItem.TOOLS_JACK:
        return 'الأدوات/الجاك';
      case VehicleItem.SECOND_SET_OF_TIRES:
        return 'مجموعة ثانية من الإطارات';
      case VehicleItem.EMERGENCY_WHEEL:
        return 'عجلة الطوارئ';
      case VehicleItem.ANTENNA:
        return 'الهوائي';
      case VehicleItem.FUEL_CARD:
        return 'بطاقة الوقود';
      case VehicleItem.FIRST_AID_KIT:
        return 'طقم الإسعافات الأولية';
      case VehicleItem.SPARE_TIRE:
        return 'الإطار الاحتياطي';
      case VehicleItem.SERVICE_BOOK:
        return 'كتاب الخدمة';
      default:
        return item.toString().split('.').last;
    }
  }

}


enum VehicleSide {
  FRONT,      // الأمام
  REAR,       // الخلف
  LEFT,       // اليسار
  RIGHT,      // اليمين
  TOP         // الأعلى
}

enum DamageType {
  DENT_BUMP,      // خدش/نتوء
  STONE_CHIP,     // رقائق حجرية
  SCRATCH_GRAZE,  // خدش/كشط
  PAINT_DAMAGE,   // ضرر طلاء
  CRACK_BREAK,    // تشقق/كسر
  MISSING         // مفقود
}

class VehicleDamage {
  final VehicleSide side;
  final DamageType type;
  final String? description;

  VehicleDamage({
    required this.side,
    required this.type,
    this.description,
  });

  factory VehicleDamage.fromJson(Map<String, dynamic> json) {
    return VehicleDamage(
      side: VehicleSide.values.firstWhere(
            (e) => e.toString().split('.').last == json['side'],
        orElse: () => VehicleSide.FRONT,
      ),
      type: DamageType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => DamageType.DENT_BUMP,
      ),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'side': side.toString().split('.').last,
      'type': type.toString().split('.').last,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleDamage &&
        other.side == side &&
        other.type == type;
  }

  @override
  int get hashCode => side.hashCode ^ type.hashCode;
}

