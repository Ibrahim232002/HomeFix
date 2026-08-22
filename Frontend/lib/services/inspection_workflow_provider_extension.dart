import '../models/inspection_model.dart';
import '../models/service_quote_model.dart';
import '../repositories/inspection_repository.dart';
import '../repositories/service_quote_repository.dart';
import 'app_state_provider.dart';

class _InspectionWorkflowState {
  final InspectionRepository inspections = InspectionRepository();
  final ServiceQuoteRepository quotes = ServiceQuoteRepository();
  final List<InspectionModel> inspectionItems = [];
  final List<ServiceQuoteModel> quoteItems = [];
}

final Expando<_InspectionWorkflowState> _inspectionStates = Expando<_InspectionWorkflowState>('homefix.inspectionWorkflow');

_InspectionWorkflowState _stateFor(AppStateProvider provider) =>
    _inspectionStates[provider] ??= _InspectionWorkflowState();

extension InspectionWorkflowProvider on AppStateProvider {
  List<InspectionModel> get inspections => List.unmodifiable(_stateFor(this).inspectionItems);
  List<ServiceQuoteModel> get serviceQuotes => List.unmodifiable(_stateFor(this).quoteItems);

  Future<InspectionModel?> loadInspectionForRequest(String requestId) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.getByRequest(requestId);
    state.inspectionItems.removeWhere((item) => item.serviceRequestId == requestId);
    if (inspection != null) state.inspectionItems.add(inspection);
    notifyListeners();
    if (inspection != null) await loadServiceQuotes(inspection.id);
    return inspection;
  }

  Future<List<ServiceQuoteModel>> loadServiceQuotes(String inspectionId) async {
    final state = _stateFor(this);
    final quotes = await state.quotes.getByInspection(inspectionId);
    state.quoteItems
      ..removeWhere((item) => item.inspectionId == inspectionId)
      ..addAll(quotes);
    notifyListeners();
    return quotes;
  }

  Future<InspectionModel> scheduleInspection(String inspectionId, DateTime scheduledAt) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.schedule(inspectionId, scheduledAt);
    _replaceInspection(state, inspection);
    notifyListeners();
    return inspection;
  }

  Future<InspectionModel> startInspection(String inspectionId) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.start(inspectionId);
    _replaceInspection(state, inspection);
    notifyListeners();
    return inspection;
  }

  Future<InspectionModel> completeInspection(String inspectionId, {String? findings}) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.complete(inspectionId, findings: findings);
    _replaceInspection(state, inspection);
    notifyListeners();
    return inspection;
  }

  Future<InspectionModel> cancelInspection(String inspectionId) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.cancel(inspectionId);
    _replaceInspection(state, inspection);
    notifyListeners();
    return inspection;
  }

  Future<InspectionModel> markInspectionNoShow(String inspectionId) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.noShow(inspectionId);
    _replaceInspection(state, inspection);
    notifyListeners();
    return inspection;
  }

  Future<ServiceQuoteModel> createServiceQuote({required String inspectionId, required double amount, String? notes, DateTime? expiresAt}) async {
    final state = _stateFor(this);
    final quote = await state.quotes.create(inspectionId: inspectionId, amount: amount, notes: notes, expiresAt: expiresAt);
    await loadServiceQuotes(inspectionId);
    return quote;
  }

  Future<ServiceQuoteModel> createServiceQuoteRevision({required String quoteId, required double amount, String? notes, DateTime? expiresAt}) async {
    final state = _stateFor(this);
    final quote = await state.quotes.createRevision(quoteId: quoteId, amount: amount, notes: notes, expiresAt: expiresAt);
    await loadServiceQuotes(quote.inspectionId);
    return quote;
  }

  Future<void> acceptServiceQuote(String quoteId, String inspectionId) async {
    final state = _stateFor(this);
    final inspection = await state.inspections.getById(inspectionId);
    await state.quotes.accept(quoteId);
    await loadServiceQuotes(inspectionId);
    if (inspection != null && inspection.serviceRequestId.isNotEmpty) {
      await loadBookingForRequest(inspection.serviceRequestId);
    }
  }

  Future<void> rejectServiceQuote(String quoteId, String inspectionId) async {
    final state = _stateFor(this);
    await state.quotes.reject(quoteId);
    await loadServiceQuotes(inspectionId);
  }

  void _replaceInspection(_InspectionWorkflowState state, InspectionModel inspection) {
    state.inspectionItems.removeWhere((item) => item.id == inspection.id);
    state.inspectionItems.add(inspection);
  }
}
