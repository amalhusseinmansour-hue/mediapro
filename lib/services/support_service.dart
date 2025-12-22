import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/support_ticket_model.dart';
import 'auth_service.dart';
import 'phone_auth_service.dart';

class SupportService extends GetxController {
  static const String _ticketsBoxName = 'supportTickets';

  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxBool isLoading = false.obs;

  AuthService? get _authService {
    try {
      return Get.find<AuthService>();
    } catch (e) {
      return null;
    }
  }

  PhoneAuthService? get _phoneAuthService {
    try {
      return Get.find<PhoneAuthService>();
    } catch (e) {
      return null;
    }
  }

  String? get _currentUserId {
    // Try AuthService first
    final authUser = _authService?.currentUser.value;
    if (authUser != null) return authUser.id;

    // Try PhoneAuthService
    final phoneUser = _phoneAuthService?.currentFirebaseUser;
    if (phoneUser != null) return phoneUser.phoneNumber ?? phoneUser.uid;

    // No fallback - user must be authenticated
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  // Get tickets box
  Future<Box<SupportTicketModel>> get _ticketsBox async {
    if (!Hive.isBoxOpen(_ticketsBoxName)) {
      return await Hive.openBox<SupportTicketModel>(_ticketsBoxName);
    }
    return Hive.box<SupportTicketModel>(_ticketsBoxName);
  }

  // Load all tickets for current user
  Future<void> loadTickets() async {
    try {
      isLoading.value = true;
      final box = await _ticketsBox;
      final userId = _currentUserId;

      if (userId == null) {
        tickets.clear();
        return;
      }

      // Get all tickets for current user
      final allTickets = box.values.where((ticket) => ticket.userId == userId).toList();

      // Sort by creation date (newest first)
      allTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      tickets.value = allTickets;
    } catch (e) {
      print('Error loading tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create new ticket
  Future<SupportTicketModel?> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    TicketPriority priority = TicketPriority.medium,
  }) async {
    try {
      isLoading.value = true;
      final userId = _currentUserId;

      if (userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      const uuid = Uuid();
      final ticket = SupportTicketModel(
        id: uuid.v4(),
        userId: userId,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      );

      // Save to Hive
      final box = await _ticketsBox;
      await box.put(ticket.id, ticket);

      // Add to list
      tickets.insert(0, ticket);

      return ticket;
    } catch (e) {
      print('Error creating ticket: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get ticket by ID
  Future<SupportTicketModel?> getTicketById(String ticketId) async {
    try {
      final box = await _ticketsBox;
      return box.get(ticketId);
    } catch (e) {
      print('Error getting ticket: $e');
      return null;
    }
  }

  // Update ticket status (for demo purposes - would be done by admin in real app)
  Future<void> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    try {
      final box = await _ticketsBox;
      final ticket = box.get(ticketId);

      if (ticket == null) return;

      final updatedTicket = SupportTicketModel(
        id: ticket.id,
        userId: ticket.userId,
        subject: ticket.subject,
        description: ticket.description,
        category: ticket.category,
        priority: ticket.priority,
        status: newStatus,
        createdAt: ticket.createdAt,
        updatedAt: DateTime.now(),
        resolvedAt: newStatus == TicketStatus.resolved || newStatus == TicketStatus.closed
            ? DateTime.now()
            : ticket.resolvedAt,
        response: ticket.response,
        adminNote: ticket.adminNote,
      );

      await box.put(ticketId, updatedTicket);

      // Update in list
      final index = tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        tickets[index] = updatedTicket;
      }
    } catch (e) {
      print('Error updating ticket status: $e');
    }
  }

  // Add response to ticket (for demo - would be admin function in real app)
  Future<void> addResponseToTicket(String ticketId, String response) async {
    try {
      final box = await _ticketsBox;
      final ticket = box.get(ticketId);

      if (ticket == null) return;

      final updatedTicket = SupportTicketModel(
        id: ticket.id,
        userId: ticket.userId,
        subject: ticket.subject,
        description: ticket.description,
        category: ticket.category,
        priority: ticket.priority,
        status: TicketStatus.inProgress,
        createdAt: ticket.createdAt,
        updatedAt: DateTime.now(),
        resolvedAt: ticket.resolvedAt,
        response: response,
        adminNote: ticket.adminNote,
      );

      await box.put(ticketId, updatedTicket);

      // Update in list
      final index = tickets.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        tickets[index] = updatedTicket;
      }
    } catch (e) {
      print('Error adding response: $e');
    }
  }

  // Delete ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      final box = await _ticketsBox;
      await box.delete(ticketId);

      tickets.removeWhere((t) => t.id == ticketId);
    } catch (e) {
      print('Error deleting ticket: $e');
    }
  }

  // Get tickets count by status
  int getTicketCountByStatus(TicketStatus status) {
    return tickets.where((ticket) => ticket.status == status).length;
  }

  // Get open tickets count
  int get openTicketsCount => getTicketCountByStatus(TicketStatus.open);

  // Get in progress tickets count
  int get inProgressTicketsCount => getTicketCountByStatus(TicketStatus.inProgress);

  // Get resolved tickets count
  int get resolvedTicketsCount => getTicketCountByStatus(TicketStatus.resolved);

  // Check if user has any open tickets
  bool get hasOpenTickets => openTicketsCount > 0;
}
