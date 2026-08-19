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
    final authResponse = await _authRepo.login(
      LoginRequest(email: email, password: password),
    );
    return UserModel(
      id: (authResponse.userId ?? 1).toString(),
      fullName: authResponse.fullName ?? 'المستخدم',
      phoneNumber: '',
      email: authResponse.email ?? email,
      role: authResponse.role == 'Technician' ? UserRole.technician : (authResponse.role == 'Customer' ? UserRole.customer : role),
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    await _authRepo.register(request);
    final userRole = request.role == 'Technician' ? UserRole.technician : UserRole.customer;
    return await login(request.email, request.password, userRole);
  }

  @override
  Future<UserModel> loginWithPhone(String phoneNumber, String otp, UserRole role) async {
    final authResponse = await _authRepo.login(
      LoginRequest(email: phoneNumber, password: 'password123'),
    );
    return UserModel(
      id: (authResponse.userId ?? 1).toString(),
      fullName: authResponse.fullName ?? 'المستخدم',
      phoneNumber: phoneNumber,
      email: authResponse.email ?? '',
      role: authResponse.role == 'Technician' ? UserRole.technician : UserRole.customer,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId != null) {
      try {
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
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final intUserId = int.tryParse(address.userId);
    if (intUserId == null) throw Exception('معرف المستخدم غير صالح');
    if (address.cityId == null || address.governorateId == null) {
      throw Exception('يرجى اختيار المحافظة والمدينة');
    }

    final dto = await _addressRepo.createAddress(
      CreateAddressRequest(
        customerId: intUserId,
        label: address.title,
        cityId: address.cityId,
        governorateId: address.governorateId,
        fullAddress: address.street,
        buildingNumber: address.building,
        floorNumber: address.floor,
        apartmentNumber: address.apartment,
        isDefault: address.isDefault,
      ),
    );
    return address.copyWith(id: dto.id.toString());
  }

  @override
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    return _notifRepo.getUserNotifications(userId);
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notifRepo.markAsRead(notificationId);
  }
}
