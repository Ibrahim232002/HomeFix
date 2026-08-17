import 'package:flutter_test/flutter_test.dart';

import 'package:homefix/models/api_dtos.dart';
import 'package:homefix/models/booking_model.dart';
import 'package:homefix/models/service_request_offer_model.dart';
import 'package:homefix/models/user_model.dart';

void main() {
  group('auth contract', () {
    test('parses backend auth response', () {
      final dto = AuthResponseDto.fromJson({
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'userId': 42,
        'fullName': 'Customer',
        'email': 'customer@example.com',
        'role': 'Customer',
      });

      expect(dto.accessToken, 'access');
      expect(dto.refreshToken, 'refresh');
      expect(dto.userId, 42);
      expect(dto.role, 'Customer');
    });

    test('maps unknown role safely to customer', () {
      expect(UserRole.fromString('unknown'), UserRole.customer);
      expect(UserRole.fromString('Technician'), UserRole.technician);
    });
  });

  group('booking contract', () {
    test('maps all backend booking lifecycle states', () {
      expect(BookingStatus.fromString('Confirmed'), BookingStatus.upcoming);
      expect(BookingStatus.fromString('Arrived'), BookingStatus.arrived);
      expect(BookingStatus.fromString('InProgress'), BookingStatus.inProgress);
      expect(BookingStatus.fromString('AwaitingCompletion'), BookingStatus.awaitingCompletion);
      expect(BookingStatus.fromString('Completed'), BookingStatus.completed);
      expect(BookingStatus.fromString('Cancelled'), BookingStatus.cancelled);
    });
  });

  group('offer contract', () {
    test('parses backend service-request offer response', () {
      final offer = ServiceRequestOfferModel.fromJson({
        'id': 5,
        'serviceRequestId': 12,
        'technicianId': 8,
        'technicianName': 'Ahmed',
        'proposedPrice': 750,
        'technicianNote': 'Available tomorrow',
        'status': 'Pending',
        'createdAt': '2026-08-17T03:00:00Z',
        'expiresAt': null,
        'respondedAt': null,
      });

      expect(offer.id, '5');
      expect(offer.serviceRequestId, '12');
      expect(offer.technicianId, '8');
      expect(offer.proposedPrice, 750);
      expect(offer.status, 'Pending');
    });
  });
}
