import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_dtos.dart';

abstract class ISupportRepository {
  Future<SupportTicketDto> getTicketById(int id);
  Future<List<SupportTicketDto>> getTicketsByUser(int userId);
  Future<SupportTicketDto> createTicket(CreateSupportTicketRequest request);
  Future<SupportTicketDto> updateTicket(int id, UpdateSupportTicketRequest request);

  Future<List<SupportMessageDto>> getMessagesByTicket(int ticketId);
  Future<SupportMessageDto> createMessage(CreateSupportMessageRequest request);
}

class SupportRepository implements ISupportRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<SupportTicketDto> getTicketById(int id) async {
    final response = await _client.get(ApiConstants.supportTicketById(id));
    return SupportTicketDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<SupportTicketDto>> getTicketsByUser(int userId) async {
    final response = await _client.get(ApiConstants.supportTicketsByUser(userId));
    if (response is List) {
      return response.map((item) => SupportTicketDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SupportTicketDto> createTicket(CreateSupportTicketRequest request) async {
    final response = await _client.post(ApiConstants.supportTickets, body: request.toJson());
    return SupportTicketDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<SupportTicketDto> updateTicket(int id, UpdateSupportTicketRequest request) async {
    final response = await _client.put(ApiConstants.supportTicketById(id), body: request.toJson());
    return SupportTicketDto.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<SupportMessageDto>> getMessagesByTicket(int ticketId) async {
    final response = await _client.get(ApiConstants.supportMessagesByTicket(ticketId));
    if (response is List) {
      return response.map((item) => SupportMessageDto.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<SupportMessageDto> createMessage(CreateSupportMessageRequest request) async {
    final response = await _client.post(ApiConstants.supportMessages, body: request.toJson());
    return SupportMessageDto.fromJson(response as Map<String, dynamic>);
  }
}
