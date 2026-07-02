// lib/shared/repositories/team_info_repository.dart
// WHY: Team info data access — sections and members from Firestore with permission checks.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/permission_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/team_info_section_schema.dart';
import '../models/team_member_schema.dart';
import '../models/user_schema.dart';

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

  Future<Result<void>> upsertSection(
      TeamInfoSectionSchema section, UserSchema author) async {
    if (!author.can(PermissionConstants.manageTeam) && !author.isSuperAdmin) {
      return const FailureResult(
          PermissionFailure('Insufficient permissions to manage team'));
    }
    try {
      await _db
          .collection('team_info_sections')
          .doc(section.key)
          .set(section.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> upsertMember(
      TeamMemberSchema member, UserSchema author) async {
    if (!author.can(PermissionConstants.manageTeam) && !author.isSuperAdmin) {
      return const FailureResult(
          PermissionFailure('Insufficient permissions to manage team'));
    }
    try {
      if (member.uid.isEmpty) {
        await _db.collection('team_members').add(member.toFirestore());
      } else {
        await _db
            .collection('team_members')
            .doc(member.uid)
            .set(member.toFirestore());
      }
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteMember(String uid, UserSchema author) async {
    if (!author.can(PermissionConstants.manageTeam) && !author.isSuperAdmin) {
      return const FailureResult(
          PermissionFailure('Insufficient permissions to manage team'));
    }
    try {
      await _db.collection('team_members').doc(uid).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
