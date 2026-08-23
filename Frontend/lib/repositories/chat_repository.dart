import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/api_dtos.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'customer_profile_repository.dart';
import 'technician_repository.dart';

abstract class IChatRepository {
  Future<List<ConversationModel>> getConversations(String userId);
  Future<ConversationModel?> getConversationById(String id);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required UserModel sender,
    required String text,
    String? attachmentUrl,
  });
  Future<ConversationModel> getOrCreateConversation({
    required String customerId,
    required String customerName,
    String? customerAvatar,
    required String technicianId,
    required String technicianName,
    String? technicianAvatar,
    String? serviceNameAr,
    String? requestId,
  });

  Future<List<ConversationDto>> getApiConversationsByUser(int profileId);
  Future<ConversationDto> getApiConversationById(int id);
  Future<ConversationDto> createApiConversation(CreateConversationRequest request);
  Future<List<MessageDto>> getApiMessagesByConversation(int conversationId);
  Future<MessageDto> createApiMessage(CreateMessageRequest request);
}

class ChatRepository implements IChatRepository {
  final ApiClient _client = ApiClient();
  final CustomerProfileRepository _customerProfiles = CustomerProfileRepository();
  final TechnicianRepository _technicians = TechnicianRepository();

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId == null || intUserId <= 0) throw Exception('معرف المستخدم غير صالح');

    try {
      final customer = await _customerProfiles.getProfileByUserId(intUserId);
      final response = await _client.get(ApiConstants.conversationsByCustomer(customer.id));
      return _mapConversationsResponse(response);
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
    }

    final technician = await _technicians.getTechnicianByUserId(userId);
    if (technician == null) throw Exception('تعذر العثور على ملف الفني المرتبط بالحساب.');
    final technicianId = int.tryParse(technician.id);
    if (technicianId == null || technicianId <= 0) throw Exception('معرف ملف الفني غير صالح');
    final response = await _client.get(ApiConstants.conversationsByTechnician(technicianId));
    return _mapConversationsResponse(response);
  }

  List<ConversationModel> _mapConversationsResponse(dynamic response) {
    if (response is! List) return [];
    return response.whereType<Map<String, dynamic>>().map((item) => ConversationDto.fromJson(item)).map((dto) => ConversationModel(
          id: dto.id.toString(),
          requestId: dto.serviceRequestId.toString(),
          serviceNameAr: 'خدمة صيانة منزلية',
          customerId: dto.customerId.toString(),
          customerName: '',
          technicianId: dto.technicianId.toString(),
          technicianName: '',
          lastMessage: 'مرحباً بك',
          lastMessageTime: dto.createdAt.isNotEmpty ? dto.createdAt : 'الآن',
          messages: const [],
        )).toList();
  }

  @override
  Future<ConversationModel?> getConversationById(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      try {
        final dto = await getApiConversationById(intId);
        final msgDtos = await getApiMessagesByConversation(dto.id);
        final messages = msgDtos
            .map((m) => MessageModel(
                  id: m.id.toString(),
                  conversationId: dto.id.toString(),
                  senderId: m.senderId.toString(),
                  senderName: m.senderId == dto.customerId ? 'العميل' : 'الفني',
                  senderRole: m.senderId == dto.customerId ? UserRole.customer : UserRole.technician,
                  text: m.messageText ?? '',
                  createdAt: m.sentAt.isNotEmpty ? m.sentAt : 'الآن',
                  isRead: m.isRead,
                ))
            .toList();

        return ConversationModel(
          id: dto.id.toString(),
          requestId: dto.serviceRequestId.toString(),
          serviceNameAr: 'خدمة صيانة منزلية',
          customerId: dto.customerId.toString(),
          customerName: '',
          technicianId: dto.technicianId.toString(),
          technicianName: '',
          lastMessage: messages.isNotEmpty ? messages.last.text : 'مرحباً بك',
          lastMessageTime: dto.createdAt.isNotEmpty ? dto.createdAt : 'الآن',
          messages: messages,
        );
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required UserModel sender,
    required String text,
    String? attachmentUrl,
  }) async {
    final intConvId = int.tryParse(conversationId);
    final intSenderId = int.tryParse(sender.id);

    if (intConvId != null && intSenderId != null) {
      final msgDto = await createApiMessage(CreateMessageRequest(
        conversationId: intConvId,
        senderId: intSenderId,
        messageText: text,
      ));
      return MessageModel(
        id: msgDto.id.toString(),
        conversationId: conversationId,
        senderId: sender.id,
        senderName: sender.fullName,
        senderRole: sender.role,
        text: msgDto.messageText ?? text,
        createdAt: msgDto.sentAt.isNotEmpty ? msgDto.sentAt : 'الآن',
        isRead: false,
      );
    }
    throw Exception('تعذر إرسال الرسالة');
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String customerId,
    required String customerName,
    String? customerAvatar,
    required String technicianId,
    required String technicianName,
    String? technicianAvatar,
    String? serviceNameAr,
    String? requestId,
  }) async {
    final intCustomer = int.tryParse(customerId);
    final intTech = int.tryParse(technicianId);
    final intRequest = requestId != null ? int.tryParse(requestId) : 0;

    if (intCustomer == null || intTech == null) {
      throw Exception('بيانات المحادثة غير مكتملة');
    }

    final dto = await createApiConversation(CreateConversationRequest(
      customerId: intCustomer,
      technicianId: intTech,
      serviceRequestId: intRequest ?? 0,
    ));
    return ConversationModel(
      id: dto.id.toString(),
      requestId: requestId,
      serviceNameAr: serviceNameAr ?? 'خدمة صيانة',
      customerId: customerId,
      customerName: customerName,
      customerAvatar: customerAvatar,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianAvatar: technicianAvatar,
      lastMessage: 'مرحباً، تم بدء المحادثة.',
      lastMessageTime: 'الآن',
      messages: [],
    );
  }

  @override
  Future<List<ConversationDto>> getApiConversationsByUser(int profileId) async {
    final response = await _client.get(ApiConstants.conversationsByCustomer(profileId));
    if (response is List) {
      return response.map((item) => ConversationDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ConversationDto> getApiConversationById(int id) async {
    final response = await _client.get(ApiConstants.conversationById(id));
    return ConversationDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ConversationDto> createApiConversation(CreateConversationRequest request) async {
    final response = await _client.post(ApiConstants.conversations, body: request.toJson());
    return ConversationDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<MessageDto>> getApiMessagesByConversation(int conversationId) async {
    final response = await _client.get(ApiConstants.messagesByConversation(conversationId));
    if (response is List) {
      return response.map((item) => MessageDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<MessageDto> createApiMessage(CreateMessageRequest request) async {
    final response = await _client.post(ApiConstants.messages, body: request.toJson());
    return MessageDto.fromJson(response as Map<String, dynamic>);
  }
}
