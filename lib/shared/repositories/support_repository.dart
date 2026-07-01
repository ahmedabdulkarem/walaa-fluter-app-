// lib/shared/repositories/support_repository.dart
// WHY: Support ticket data access from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/support_ticket_schema.dart';

class SupportRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<SupportTicketSchema>> streamUserTickets(String uid) {
    return _db
        .collection('support_tickets')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SupportTicketSchema.fromFirestore).toList());
  }

  Stream<List<SupportTicketSchema>> streamAllTickets() {
    return _db
        .collection('support_tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SupportTicketSchema.fromFirestore).toList());
  }

  Future<Result<void>> createTicket(SupportTicketSchema ticket) async {
    try {
      await _db.collection('support_tickets').doc(ticket.uid).set(ticket.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateTicket(
    String ticketUid,
    Map<String, dynamic> updates,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (updates.containsKey('status')) updateData['status'] = updates['status'];
      if (updates.containsKey('assignedTo')) updateData['assignedTo'] = updates['assignedTo'];
      if (updates.containsKey('response')) updateData['response'] = updates['response'];
      await _db.collection('support_tickets').doc(ticketUid).update(updateData);
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
