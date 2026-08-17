import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

abstract class IChatRepository {
  Future<List<ConversationModel>> getConversations(String userId, UserRole role);
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
  Future<List<ConversationDto>> getApiConversationsByProfile(int profileId, UserRole role);
  Future<ConversationDto> getApiConversationById(int id);
  Future<ConversationDto> createApiConversation(CreateConversationRequest request);
  Future<List<MessageDto>> getApiMessagesByConversation(int conversationId);
  Future<MessageDto> createApiMessage(CreateMessageRequest request);
}

class ChatRepository implements IChatRepository {
  final ApiClient _client = ApiClient();

  Future<int?> _resolveProfileId(String userId, UserRole role) async {
    final intUserId = int.tryParse(userId);
    if (intUserId == null) return null;
    final endpoint = role == UserRole.customer
        ? ApiConstants.customerProfileByUser(intUserId)
        : ApiConstants.technicianProfileByUser(intUserId);
    try {
      final response = await _client.get(endpoint);
      if (response is Map<String, dynamic>) {
        final id = response['id'];
        return id is int ? id : int.tryParse(id?.toString() ?? '');
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId, UserRole role) async {
    final profileId = await _resolveProfileId(userId, role);
    if (profileId == null) return [];

    final dtos = await getApiConversationsByProfile(profileId, role);
    final result = <ConversationModel>[];
    for (final dto in dtos) {
      final msgDtos = await getApiMessagesByConversation(dto.id);
      final messages = msgDtos
          .map((m) => MessageModel(
                id: m.id.toString(),
                conversationId: dto.id.toString(),
                senderId: m.senderId.toString(),
                senderName: m.senderId.toString() == userId ? 'أنت' : 'مشارك آخر',
                senderRole: m.senderId.toString() == userId
                    ? role
                    : (role == UserRole.customer ? UserRole.technician : UserRole.customer),
                text: m.messageText ?? '',
                createdAt: m.sentAt,
                isRead: m.isRead,
              ))
          .toList();

      result.add(ConversationModel(
        id: dto.id.toString(),
        requestId: dto.serviceRequestId.toString(),
        serviceNameAr: '',
        customerId: dto.customerId.toString(),
        customerName: '',
        technicianId: dto.technicianId.toString(),
        technicianName: '',
        lastMessage: messages.isNotEmpty ? messages.last.text : '',
        lastMessageTime: messages.isNotEmpty ? messages.last.createdAt : dto.createdAt,
        messages: messages,
      ));
    }
    return result;
  }

  @override
  Future<ConversationModel?> getConversationById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final dto = await getApiConversationById(intId);
    final msgDtos = await getApiMessagesByConversation(dto.id);
    return ConversationModel(
      id: dto.id.toString(),
      requestId: dto.serviceRequestId.toString(),
      serviceNameAr: '',
      customerId: dto.customerId.toString(),
      customerName: '',
      technicianId: dto.technicianId.toString(),
      technicianName: '',
      lastMessage: msgDtos.isNotEmpty ? msgDtos.last.messageText ?? '' : '',
      lastMessageTime: msgDtos.isNotEmpty ? msgDtos.last.sentAt : dto.createdAt,
      messages: msgDtos
          .map((m) => MessageModel(
                id: m.id.toString(),
                conversationId: dto.id.toString(),
                senderId: m.senderId.toString(),
                senderName: '',
                senderRole: UserRole.customer,
                text: m.messageText ?? '',
                createdAt: m.sentAt,
                isRead: m.isRead,
              ))
          .toList(),
    );
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required UserModel sender,
    required String text,
    String? attachmentUrl,
  }) async {
    final conversationIdInt = int.tryParse(conversationId);
    final senderIdInt = int.tryParse(sender.id);
    if (conversationIdInt == null || senderIdInt == null) {
      throw ArgumentError('بيانات الرسالة غير صالحة');
    }
    if (text.trim().isEmpty && (attachmentUrl == null || attachmentUrl.trim().isEmpty)) {
      throw ArgumentError('لا يمكن إرسال رسالة فارغة');
    }

    final msgDto = await createApiMessage(CreateMessageRequest(
      conversationId: conversationIdInt,
      senderId: senderIdInt,
      messageText: text.trim(),
      attachmentUrl: attachmentUrl,
    ));
    return MessageModel(
      id: msgDto.id.toString(),
      conversationId: conversationId,
      senderId: sender.id,
      senderName: sender.fullName,
      senderRole: sender.role,
      text: msgDto.messageText ?? text.trim(),
      createdAt: msgDto.sentAt,
      isRead: msgDto.isRead,
    );
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
    final customerUserId = int.tryParse(customerId);
    final technicianIdInt = int.tryParse(technicianId);
    final requestIdInt = int.tryParse(requestId ?? '');
    if (customerUserId == null || technicianIdInt == null || requestIdInt == null || requestIdInt <= 0) {
      throw ArgumentError('المحادثة تتطلب حجزاً/طلب خدمة صالحاً');
    }

    final dto = await createApiConversation(CreateConversationRequest(
      customerId: customerUserId,
      technicianId: technicianIdInt,
      serviceRequestId: requestIdInt,
    ));

    return ConversationModel(
      id: dto.id.toString(),
      requestId: requestId,
      serviceNameAr: serviceNameAr ?? '',
      customerId: customerId,
      customerName: customerName,
      customerAvatar: customerAvatar,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianAvatar: technicianAvatar,
      lastMessage: '',
      lastMessageTime: dto.createdAt,
      messages: const [],
    );
  }

  @override
  Future<List<ConversationDto>> getApiConversationsByProfile(int profileId, UserRole role) async {
    final response = role == UserRole.customer
        ? await _client.get(ApiConstants.conversationsByCustomer(profileId))
        : await _client.get(ApiConstants.conversationsByTechnician(profileId));
    if (response is! List) return [];
    return response.map((item) => ConversationDto.fromJson(item as Map<String, dynamic>)).toList();
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
    if (response is! List) return [];
    return response.map((item) => MessageDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<MessageDto> createApiMessage(CreateMessageRequest request) async {
    final response = await _client.post(ApiConstants.messages, body: request.toJson());
    return MessageDto.fromJson(response as Map<String, dynamic>);
  }
}
