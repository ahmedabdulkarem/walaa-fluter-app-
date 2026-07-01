// lib/shared/repositories/team_info_repository.dart
// WHY: Team info data access — sections and members from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_info_section_schema.dart';
import '../models/team_member_schema.dart';

class TeamInfoRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<TeamInfoSectionSchema>> streamSections() {
    return _db
        .collection('team_info_sections')
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(TeamInfoSectionSchema.fromFirestore).toList());
  }

  Stream<List<TeamMemberSchema>> streamMembers() {
    return _db
        .collection('team_members')
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(TeamMemberSchema.fromFirestore).toList());
  }

  Future<void> upsertSection(TeamInfoSectionSchema section) async {
    await _db.collection('team_info_sections').doc(section.key).set(section.toFirestore());
  }

  Future<void> upsertMember(TeamMemberSchema member) async {
    if (member.uid.isEmpty) {
      await _db.collection('team_members').add(member.toFirestore());
    } else {
      await _db.collection('team_members').doc(member.uid).set(member.toFirestore());
    }
  }

  Future<void> deleteMember(String uid) async {
    await _db.collection('team_members').doc(uid).delete();
  }
}
