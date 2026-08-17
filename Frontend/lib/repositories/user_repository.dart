import '../models/user_model.dart';
import '../models/address_model.dart';
import '../models/notification_model.dart';
import 'auth_repository.dart';
import 'address_repository.dart';
import 'notification_repository.dart';
import '../models/api_dtos.dart';

abstract class IUserRepository {
  Future<UserModel> login(String email, String password, UserRole role);
  Future<UserModel> register(RegisterRequest request);
  Future<UserModel> loginWithPhone(String phoneNumber, String otp, UserRole role);
  Future<List<AddressModel>> getUserAddresses(String userId);
  Future<AddressModel> addAddress(AddressModel address);
  Future<List<NotificationModel>> getUserNotifications(String userId);
  Future<void> markNotificationAsRead(String notificationId);
}

class UserRepository implements IUserRepository {
  final AuthRepository _authRepo = AuthRepository();
  final AddressRepository _addressRepo = AddressRepository();
  final NotificationRepository _notifRepo = NotificationRepository();

  @override
  Future<UserModel> login(String email, String password, UserRole role) async {
    final authResponse = await _authRepo.login(LoginRequest(email: email, password: password));
    return UserModel(
      id: (authResponse.userId ?? 0).toString(),
      fullName: authResponse.fullName ?? 'المستخدم',
      phoneNumber: '',
      email: authResponse.email ?? email,
      role: UserRole.fromString(authResponse.role ?? role.nameStr),
      createdAt: '',
    );
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    await _authRepo.register(request);
    throw StateError('Registration requires email verification before authentication.');
  }

  @override
  Future<UserModel> loginWithPhone(String phoneNumber, String otp, UserRole role) async {
    throw UnsupportedError('Phone/SMS OTP login is not exposed by the current backend contract.');
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId == null) return [];
    final dtos = await _addressRepo.getAddressesByCustomerId(intUserId);
    return dtos
        .map((d) => AddressModel(
              id: d.id.toString(),
              userId: d.customerId.toString(),
              title: d.label ?? d.buildingNumber ?? 'العنوان المسجل',
              governorate: '',
              city: '',
              street: d.fullAddress ?? '',
              building: d.buildingNumber ?? '',
              floor: d.floorNumber ?? '',
              apartment: d.apartmentNumber ?? '',
              isDefault: d.isDefault,
              governorateId: d.governorateId,
              cityId: d.cityId,
            ))
        .toList();
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final intUserId = int.tryParse(address.userId);
    if (intUserId == null) throw ArgumentError('معرف المستخدم غير صالح');
    final dto = await _addressRepo.createAddress(
      CreateAddressRequest(
        customerId: intUserId,
        label: address.title,
        fullAddress: address.street,
        buildingNumber: address.building,
        floorNumber: address.floor,
        apartmentNumber: address.apartment,
        additionalInstructions: address.landmark,
        isDefault: address.isDefault,
        governorateId: address.governorateId,
        cityId: address.cityId,
      ),
    );
    return address.copyWith(id: dto.id.toString());
  }

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async => _notifRepo.getUserNotifications(userId);

  @override
  Future<void> markNotificationAsRead(String notificationId) async => _notifRepo.markAsRead(notificationId);
}
