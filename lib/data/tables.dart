import 'package:drift/drift.dart';

// Enum definitions matching Java entities
enum ItemType { DRUG, CONSUMABLE_DEVICE }

enum UserRole { Owner, Pharmacist, Nurse, Assistant, Manager }

enum Unit {
  AMPOULE,
  BOTTLE,
  BOX,
  BOX_OF_12_PESSARIES,
  BOX_OF_12_TABLETS,
  BOX_OF_14_TABLETS,
  BOX_OF_18_PESSARIES,
  BOX_OF_18_TABLETS,
  BOX_OF_1_PESSARY,
  BOX_OF_24_TABLETS,
  BOX_OF_3_PESSARIES,
  BOX_OF_6_PESSARIES,
  BOX_OF_6_TABLETS,
  BOX_OF_7_PESSARIES,
  CAPSULE,
  DOSE,
  KIT_OF_ONE_DAY_DOSE,
  PESSARY,
  PIECE,
  Pc_s,
  ROLL,
  SACHET,
  SUPPOSITORY,
  TABLET,
  TUBE,
  TUBE_OF_15_TABLETS,
  TUBE_OF_20_TABLETS,
  UNKNOWN,
  VIAL,
}

enum AuthorisedLevel { All, HOSPITAL_USE_DRUG }

enum MustPrescribedBy {
  All,
  Cardiologist,
  Dental_Surgeon,
  Dentist_Or_Stomatologist,
  Dermatologist,
  Dermatologist_Or_Allergologist,
  Dermatologist_Or_Pediatrician,
  Gynecologist,
  Gynecologist_Or_Oncologist,
  Gynecologist_Or_Orthopedist,
  Gynecologist_Or_Urologist,
  Internal_Medicine_Or_Internal_Medicine_Specialist,
  Internal_Medicine_Or_Internal_Medicine_Specialist_Or_Ent_Specialist,
  Internal_Medicine_Or_Internal_Medicine_Specialist_Or_Pediatrician,
  Internal_Medicine_Or_Internal_Medicine_Specialist_Or_Surgeon,
  Nephrologist_Or_Cardiologist_Or_Or_Urologist,
  Neurologist_Or_Psychiatrist,
  Pediatrician,
  Pediatrician_Or_Ent_Specialist,
}

enum StockRequestStatus { DRAFT, SUBMITTED, RECEIVED }

enum ActivationStatus { PENDING, ACTIVE, INACTIVE }

enum SubscriptionTier { FREE, MONTHLY, YEARLY }

enum ServiceType { PHARMACY, CLINIC, HOSPITAL }

enum DeviceType { PHARMACY_RETAIL, PHARMACY_WHOLESALE, CLINIC_INVENTORY }

enum DeviceRole { ADMIN, NORMAL }

enum ModuleSubtype {
  CLINIC_INVENTORY,
  PHARMACY_RETAIL,
  PHARMACY_WHOLESALE,
  CLINIC,
  HOSPITAL,
}

enum ClinicService { DENTAL, INTERNAL_MEDICINE, LABORATORY, SURGERY, PEDIATRICS, CARDIOLOGY, ORTHOPEDICS }

// Insurance table
class Insurances extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255).unique()();
  TextColumn get acronym => text().withLength(min: 1, max: 50).unique()();
  RealColumn get clientPercentage => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Products table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 500)();
  TextColumn get type => textEnum<ItemType>()();
  TextColumn get description => text().nullable()();
  TextColumn get sellingUnit =>
      text().nullable()(); // ProductMetadata embedded field
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ProductInsurances junction table
class ProductInsurances extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  IntColumn get utilizationCount => integer().nullable()();
  TextColumn get unit => textEnum<Unit>()();
  RealColumn get cost => real()();
  TextColumn get authorisedLevel => textEnum<AuthorisedLevel>()();
  TextColumn get mustPrescribedBy => textEnum<MustPrescribedBy>()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get insuranceId => text().references(Insurances, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// StockIns table
class StockIns extends Table {
  TextColumn get id => text()();
  IntColumn get quantity => integer()();
  TextColumn get location => text().nullable()();
  RealColumn get pricePerUnit => real().nullable()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  IntColumn get reorderLevel => integer().nullable()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get userId => text().nullable().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// StockOutSales table  
class StockOutSales extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get stockOutId => text().references(StockOuts, #id)();
  TextColumn get patientName => text()();
  TextColumn get destinationClinicService => text().nullable()();
  TextColumn get insuranceCardNumber => text().nullable()();
  TextColumn get issuingCompany => text().nullable()();
  TextColumn get prescriberName => text().nullable()();
  TextColumn get prescriberLicenseId => text().nullable()();
  TextColumn get prescribingOrganization => text().nullable()();
  RealColumn get totalPrice => real()();
  TextColumn get userId => text().nullable().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// StockOuts table
class StockOuts extends Table {
  TextColumn get id => text()();
  TextColumn get stockInId => text().references(StockIns, #id)();
  IntColumn get quantitySold => integer()();
  RealColumn get pricePerUnit => real()();
  TextColumn get insuranceId => text().nullable()();
  RealColumn get itemTotal => real()();
  RealColumn get patientPays => real()();
  RealColumn get insurancePays => real()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Users table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get names => text().withLength(min: 1, max: 255)();
  TextColumn get phoneNumber => text().withLength(min: 1, max: 50)();
  TextColumn get email => text().nullable()();
  TextColumn get password => text().withLength(min: 6, max: 60)();
  TextColumn get role => textEnum<UserRole>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// StockRequests table
class StockRequests extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get requestNumber => text().unique()();
  DateTimeColumn get requestDate => dateTime()();
  DateTimeColumn get neededByDate => dateTime().nullable()();
  TextColumn get status => textEnum<StockRequestStatus>()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// StockRequestItems table
class StockRequestItems extends Table {
  TextColumn get id => text()();
  TextColumn get requestId =>
      text().references(StockRequests, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantityRequested => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Modules table for app activation
class Modules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get moduleCode => text().nullable()();
  TextColumn get publicKey => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get province => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get sector => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get activationStatus => textEnum<ActivationStatus>()();
  DateTimeColumn get activationTime => dateTime().nullable()();
  TextColumn get subscriptionTier => textEnum<SubscriptionTier>().nullable()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get serviceType => textEnum<ServiceType>().nullable()();
  TextColumn get subType => textEnum<ModuleSubtype>().nullable()();
  TextColumn get privateKey => text().nullable()();
}

// Devices table for device registration and status
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get moduleId => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get appVersion => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get lastAction => text().nullable()();
  TextColumn get deviceType => text().nullable()();
  TextColumn get activationStatus => textEnum<ActivationStatus>()();
  BoolColumn get supportMultiUsers => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

// Payment Methods table for module payment configurations
class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moduleId =>
      integer().references(Modules, #id, onDelete: KeyAction.cascade)();
  TextColumn get account => text()();
  TextColumn get currency => text().nullable()();
  TextColumn get type => text()(); // MOMO, Bank, Card, etc.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Workers table for user profiles synced from server
class Workers extends Table {
  TextColumn get id => text()(); // UUID from server
  IntColumn get moduleId =>
      integer().references(Modules, #id, onDelete: KeyAction.cascade)();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get role => textEnum<UserRole>()();
  TextColumn get pinHash => text().nullable()(); // Hashed PIN
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

