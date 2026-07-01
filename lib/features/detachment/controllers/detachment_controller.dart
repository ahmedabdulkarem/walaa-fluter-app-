import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detachment_member_model.dart';
import '../repositories/detachment_repository.dart';
import '../../../app.dart';

class DetachmentMemberSelectionState {
  final String searchQuery;
  final Set<String> selectedMemberIds;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccess;

  const DetachmentMemberSelectionState({
    this.searchQuery = '',
    this.selectedMemberIds = const {},
    this.isSaving = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  DetachmentMemberSelectionState copyWith({
    String? searchQuery,
    Set<String>? selectedMemberIds,
    bool? isSaving,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return DetachmentMemberSelectionState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMemberIds: selectedMemberIds ?? this.selectedMemberIds,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  List<DetachmentMemberModel> filterMembers(
    List<DetachmentMemberModel> allMembers,
  ) {
    if (searchQuery.isEmpty) return allMembers;
    final query = searchQuery.toLowerCase();
    return allMembers
        .where((m) => m.name.toLowerCase().contains(query))
        .toList();
  }
}

class DetachmentMemberSelectionNotifier
    extends StateNotifier<DetachmentMemberSelectionState> {
  final DetachmentRepository _repository;

  DetachmentMemberSelectionNotifier(this._repository)
      : super(const DetachmentMemberSelectionState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleMember(String memberId) {
    final updated = Set<String>.from(state.selectedMemberIds);
    if (updated.contains(memberId)) {
      updated.remove(memberId);
    } else {
      updated.add(memberId);
    }
    state = state.copyWith(selectedMemberIds: updated);
  }

  void initSelection(List<String> memberIds) {
    state = state.copyWith(
      selectedMemberIds: Set<String>.from(memberIds),
      isSuccess: false,
      errorMessage: null,
    );
  }

  Future<bool> saveShiftMembers(String shiftId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    final result = await _repository.updateShiftMembers(
      shiftId,
      state.selectedMemberIds.toList(),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isSaving: false, isSuccess: true);
        return true;
      },
    );
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

final detachmentMemberSelectionProvider = StateNotifierProvider<
    DetachmentMemberSelectionNotifier,
    DetachmentMemberSelectionState>((ref) {
  final repo = ref.watch(detachmentNewRepoProvider);
  return DetachmentMemberSelectionNotifier(repo);
});
