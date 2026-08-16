import 'user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String text;
  final String? attachmentUrl;
  final String? attachmentType; // 'image' | 'file'
  final String createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole.nameStr,
        'text': text,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] ?? '',
        conversationId: json['conversationId'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        senderRole: UserRole.fromString(json['senderRole'] ?? 'Customer'),
        text: json['text'] ?? '',
        attachmentUrl: json['attachmentUrl'],
        attachmentType: json['attachmentType'],
        createdAt: json['createdAt'] ?? '',
        isRead: json['isRead'] ?? false,
      );
}

class ConversationModel {
  final String id;
  final String? requestId;
  final String? serviceNameAr;
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  final String technicianId;
  final String technicianName;
  final String? technicianAvatar;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCountCustomer;
  final int unreadCountTechnician;
  final List<MessageModel> messages;

  ConversationModel({
    required this.id,
    this.requestId,
    this.serviceNameAr,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.technicianId,
    required this.technicianName,
    this.technicianAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCountCustomer = 0,
    this.unreadCountTechnician = 0,
    required this.messages,
  });

  ConversationModel copyWith({
    String? id,
    String? requestId,
    String? serviceNameAr,
    String? customerId,
    String? customerName,
    String? customerAvatar,
    String? technicianId,
    String? technicianName,
    String? technicianAvatar,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCountCustomer,
    int? unreadCountTechnician,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianAvatar: technicianAvatar ?? this.technicianAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCountCustomer: unreadCountCustomer ?? this.unreadCountCustomer,
      unreadCountTechnician: unreadCountTechnician ?? this.unreadCountTechnician,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestId': requestId,
        'serviceNameAr': serviceNameAr,
        'customerId': customerId,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'technicianId': technicianId,
        'technicianName': technicianName,
        'technicianAvatar': technicianAvatar,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'unreadCountCustomer': unreadCountCustomer,
        'unreadCountTechnician': unreadCountTechnician,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] ?? '',
        requestId: json['requestId'],
        serviceNameAr: json['serviceNameAr'],
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'] ?? '',
        customerAvatar: json['customerAvatar'],
        technicianId: json['technicianId'] ?? '',
        technicianName: json['technicianName'] ?? '',
        technicianAvatar: json['technicianAvatar'],
        lastMessage: json['lastMessage'] ?? '',
        lastMessageTime: json['lastMessageTime'] ?? '',
        unreadCountCustomer: (json['unreadCountCustomer'] as num?)?.toInt() ?? 0,
        unreadCountTechnician: (json['unreadCountTechnician'] as num?)?.toInt() ?? 0,
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((m) => MessageModel.fromJson(m))
            .toList(),
      );
}
