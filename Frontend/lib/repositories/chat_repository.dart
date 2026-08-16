import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

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

  // OpenAPI DTO methods
  Future<List<ConversationDto>> getApiConversationsByUser(int userId);
  Future<ConversationDto> getApiConversationById(int id);
  Future<ConversationDto> createApiConversation(CreateConversationRequest request);
  Future<List<MessageDto>> getApiMessagesByConversation(int conversationId);
  Future<MessageDto> createApiMessage(CreateMessageRequest request);
}

class ChatRepository implements IChatRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    final intUserId = int.tryParse(userId);
    if (intUserId != null) {
      try {
        final dtos = await getApiConversationsByUser(intUserId);
        final List<ConversationModel> result = [];
        for (final dto in dtos) {
          List<MessageModel> messages = [];
          try {
            final msgDtos = await getApiMessagesByConversation(dto.id);
            messages = msgDtos
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
          } catch (_) {}

          result.add(ConversationModel(
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
          ));
        }
        return result;
      } catch (_) {}
    }
    return [];
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

  // --- Direct OpenAPI Implementations ---
  @override
  Future<List<ConversationDto>> getApiConversationsByUser(int userId) async {
    try {
      final response = await _client.get(ApiConstants.conversationsByCustomer(userId));
      if (response is List && response.isNotEmpty) {
        return response.map((item) => ConversationDto.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    try {
      final response = await _client.get(ApiConstants.conversationsByTechnician(userId));
      if (response is List) {
        return response.map((item) => ConversationDto.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
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
