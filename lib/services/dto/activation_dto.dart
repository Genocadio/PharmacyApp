import 'package:nexxpharma/data/tables.dart';

class ModuleResponse {
  final int? id;
  final String? moduleCode;
  final String? publicKey;
  final String? name;
  final String? phone;
  final String? email;
  final String? country;
  final String? province;
  final String? district;
  final String? sector;
  final String? logoUrl;
  final ActivationStatus activationStatus;
  final DateTime? activationTime;
  final SubscriptionTier? subscriptionTier;
  final DateTime? expirationDate;
  final DateTime? timestamp;
  final double? latitude;
  final double? longitude;
  final ServiceType? serviceType;
  final ModuleSubtype? subType;
  final List<ModulePaymentMethod> paymentMethods;

  ModuleResponse({
    this.id,
    this.moduleCode,
    this.publicKey,
    this.name,
    this.phone,
    this.email,
    this.country,
    this.province,
    this.district,
    this.sector,
    this.logoUrl,
    required this.activationStatus,
    this.activationTime,
    this.subscriptionTier,
    this.expirationDate,
    this.timestamp,
    this.latitude,
    this.longitude,
    this.serviceType,
    this.subType,
    this.paymentMethods = const [],
  });

  factory ModuleResponse.fromJson(Map<String, dynamic> json) {
    final paymentMethodsList = <ModulePaymentMethod>[];
    if (json['paymentMethods'] != null) {
      paymentMethodsList.addAll(
        (json['paymentMethods'] as List).map(
          (pm) => ModulePaymentMethod.fromJson(pm as Map<String, dynamic>),
        ),
      );
    }

    return ModuleResponse(
      id: json['id'],
      moduleCode: json['moduleCode'],
      publicKey: json['publicKey'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      country: json['country'],
      province: json['province'],
      district: json['district'],
      sector: json['sector'],
      logoUrl: json['logoUrl'],
      activationStatus: ActivationStatus.values.firstWhere(
        (e) => e.name == json['activationStatus'],
        orElse: () => ActivationStatus.PENDING,
      ),
      activationTime: json['activationTime'] != null
          ? DateTime.parse(json['activationTime'])
          : null,
      subscriptionTier: json['subscriptionTier'] != null
          ? SubscriptionTier.values.firstWhere(
              (e) => e.name == json['subscriptionTier'],
              orElse: () => SubscriptionTier.FREE,
            )
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      serviceType: json['serviceType'] != null
          ? ServiceType.values.firstWhere(
              (e) => e.name == json['serviceType'],
              orElse: () => ServiceType.PHARMACY,
            )
          : null,
      subType: json['subType'] != null
          ? ModuleSubtype.values.firstWhere(
              (e) => e.name == json['subType'],
              orElse: () => ModuleSubtype.PHARMACY_RETAIL,
            )
          : null,
      paymentMethods: paymentMethodsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleCode': moduleCode,
      'publicKey': publicKey,
      'name': name,
      'phone': phone,
      'email': email,
      'country': country,
      'province': province,
      'district': district,
      'sector': sector,
      'logoUrl': logoUrl,
      'activationStatus': activationStatus.name,
      'activationTime': activationTime?.toIso8601String(),
      'subscriptionTier': subscriptionTier?.name,
      'expirationDate': expirationDate?.toIso8601String(),
      'timestamp': timestamp?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'serviceType': serviceType?.name,
      'subType': subType?.name,
      'paymentMethods': paymentMethods.map((pm) => pm.toJson()).toList(),
    };
  }
}

class DeviceRegistrationRequest {
  final String? email;
  final String? phone;
  final String code;
  final String publicKey;
  final double? latitude;
  final double? longitude;
  final String appVersion;
  final String? deviceName;

  DeviceRegistrationRequest({
    this.email,
    this.phone,
    required this.code,
    required this.publicKey,
    this.latitude,
    this.longitude,
    required this.appVersion,
    this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'code': code,
      'publicKey': publicKey,
      'latitude': latitude,
      'longitude': longitude,
      'appVersion': appVersion,
      'deviceName': deviceName,
    };
  }
}

class DeviceApiResponse<T> {
  final T? data;
  final ModuleResponse? module;
  final DeviceStatusDTO? status;
  final List<DeviceCommandDTO> commands;

  DeviceApiResponse({
    this.data,
    this.module,
    this.status,
    required this.commands,
  });

  factory DeviceApiResponse.fromJson(
    Map<String, dynamic> json, {
    T? Function(Object? data)? parseData,
  }) {
    final commandsJson = json['commands'] as List<dynamic>?;
    return DeviceApiResponse(
      data: parseData != null && json['data'] != null 
          ? parseData(json['data']) 
          : null,
      module: json['module'] != null
          ? ModuleResponse.fromJson(json['module'])
          : null,
      status: json['status'] != null
          ? DeviceStatusDTO.fromJson(json['status'])
          : null,
      commands: commandsJson != null
          ? commandsJson
              .map((command) =>
                  DeviceCommandDTO.fromJson(command as Map<String, dynamic>))
              .toList()
          : <DeviceCommandDTO>[],
    );
  }
}

class DeviceDTO {
  final int? id;
  final String? deviceId;
  final String? deviceName;
  final String? appVersion;
  final double? latitude;
  final double? longitude;
  final String? lastAction;
  final String? deviceType;
  final ActivationStatus activationStatus;
  final bool supportMultiUsers;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;

  DeviceDTO({
    this.id,
    this.deviceId,
    this.deviceName,
    this.appVersion,
    this.latitude,
    this.longitude,
    this.lastAction,
    this.deviceType,
    required this.activationStatus,
    required this.supportMultiUsers,
    this.lastSeenAt,
    this.createdAt,
  });

  factory DeviceDTO.fromJson(Map<String, dynamic> json) {
    return DeviceDTO(
      id: json['id'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      appVersion: json['appVersion'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lastAction: json['lastAction'],
      deviceType: json['deviceType'],
      activationStatus: ActivationStatus.values.firstWhere(
        (e) => e.name == json['activationStatus'],
        orElse: () => ActivationStatus.PENDING,
      ),
      supportMultiUsers: json['supportMultiUsers'] ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'appVersion': appVersion,
      'latitude': latitude,
      'longitude': longitude,
      'lastAction': lastAction,
      'deviceType': deviceType,
      'activationStatus': activationStatus.name,
      'supportMultiUsers': supportMultiUsers,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class DeviceStatusDTO {
  final bool isActive;
  final bool isSyncRequired;
  final bool supportMultiUsers;
  final String? message;

  DeviceStatusDTO({
    required this.isActive,
    required this.isSyncRequired,
    required this.supportMultiUsers,
    this.message,
  });

  factory DeviceStatusDTO.fromJson(Map<String, dynamic> json) {
    return DeviceStatusDTO(
      isActive: json['active'] ?? json['isActive'] ?? false,
      isSyncRequired: json['syncRequired'] ?? json['isSyncRequired'] ?? false,
      supportMultiUsers: json['supportMultiUsers'] ?? false,
      message: json['message'],
    );
  }
}

class DeviceCommandDTO {
  final int? id;
  final String? type;
  final String? status;
  final DateTime? createdAt;
  final DateTime? deliveredAt;
  final DateTime? acknowledgedAt;

  DeviceCommandDTO({
    this.id,
    this.type,
    this.status,
    this.createdAt,
    this.deliveredAt,
    this.acknowledgedAt,
  });

  factory DeviceCommandDTO.fromJson(Map<String, dynamic> json) {
    return DeviceCommandDTO(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'])
          : null,
    );
  }
}

class DeviceTokenRequest {
  final String moduleId;
  final String deviceId;
  final String message;
  final String signature;

  DeviceTokenRequest({
    required this.moduleId,
    required this.deviceId,
    required this.message,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'deviceId': deviceId,
      'message': message,
      'signature': signature,
    };
  }
}

class ModuleSignedRequest<T> {
  final String moduleId;
  final String deviceId;
  final String signature;
  final T? data;

  ModuleSignedRequest({
    required this.moduleId,
    required this.deviceId,
    required this.signature,
    this.data,
  });

  Map<String, dynamic> toJson(Object? Function(T? data)? encodeData) {
    return {
      'moduleId': moduleId,
      'deviceId': deviceId,
      'signature': signature,
      'data': encodeData != null ? encodeData(data) : data,
    };
  }
}

class UpdateDeviceInput {
  final String appVersion;
  final ActivationStatus activationStatus;
  final bool supportMultiUsers;
  final String? lastAction;
  final double? latitude;
  final double? longitude;

  UpdateDeviceInput({
    required this.appVersion,
    required this.activationStatus,
    required this.supportMultiUsers,
    this.lastAction,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'activationStatus': activationStatus.name,
      'supportMultiUsers': supportMultiUsers,
      'lastAction': lastAction,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UpdatePublicKeyPayload {
  final String newPublicKey;

  UpdatePublicKeyPayload({required this.newPublicKey});

  Map<String, dynamic> toJson() {
    return {'newPublicKey': newPublicKey};
  }
}

class CommandAcknowledgmentPayload {
  final int commandId;

  CommandAcknowledgmentPayload({required this.commandId});

  Map<String, dynamic> toJson() {
    return {'commandId': commandId};
  }
}

class DeviceSignedRequest<T> {
  final String deviceId;
  final String signature;
  final T? data;

  DeviceSignedRequest({
    required this.deviceId,
    required this.signature,
    this.data,
  });

  Map<String, dynamic> toJson(Object? Function(T? data)? encodeData) {
    return {
      'deviceId': deviceId,
      'signature': signature,
      'data': encodeData != null ? encodeData(data) : data,
    };
  }
}

/// Payment method DTO for module payment configurations
class ModulePaymentMethod {
  final int? id;
  final String account;
  final String? currency;
  final String type; // MOMO, Bank, Card, etc.

  ModulePaymentMethod({
    this.id,
    required this.account,
    this.currency,
    required this.type,
  });

  factory ModulePaymentMethod.fromJson(Map<String, dynamic> json) {
    return ModulePaymentMethod(
      id: json['id'],
      account: json['account'],
      currency: json['currency'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'currency': currency,
      'type': type,
    };
  }
}

/// Worker DTO for synced user profiles
class WorkerDTO {
  final String id; // UUID
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final UserRole role;
  final String? pinHash;
  final bool active;
  final int version;
  final DateTime? deletedAt;

  WorkerDTO({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    required this.role,
    this.pinHash,
    this.active = true,
    this.version = 0,
    this.deletedAt,
  });

  factory WorkerDTO.fromJson(Map<String, dynamic> json) {
    return WorkerDTO(
      id: json['workerId'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      email: json['email'],
      role: json['role'] != null
          ? UserRole.values.firstWhere(
              (e) => e.name == json['role'],
              orElse: () => UserRole.Assistant,
            )
          : UserRole.Assistant,
      pinHash: json['pin'],
      active: json['active'] ?? true,
      version: json['version'] ?? 0,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workerId': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': role.name,
      'pin': pinHash,
      'active': active,
      'version': version,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
