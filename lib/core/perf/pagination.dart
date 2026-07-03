// lib/core/perf/pagination.dart
// WHY: Several screens (workshops, applications, support tickets, posts)
//      currently load whole collections at once via `.snapshots()`. That
//      works for a few hundred docs but degrades fast as data grows. This
//      helper provides cursor-based pagination for both one-shot reads and
//      live streams, keeping memory bounded and startup time flat.
//
//      Pattern: start with `pageSize` docs; on scroll-to-bottom call
//      `fetchNext()`. The notifier exposes a flat `items` list, an
//      `isLoadingMore` flag, and a `hasMore` flag.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/exception_mapper.dart';
import '../error/failure.dart';
import '../logging/app_logger.dart';

/// Snapshot of a paginated list.
class PaginatedState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Failure? error;

  const PaginatedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Failure? error,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Generic Firestore cursor-paginated notifier.
///
/// Configure with a [queryBuilder] that returns the base query (without
/// pagination cursors) and a [mapper] that converts a doc to your model.
class PaginatedNotifier<T> extends StateNotifier<PaginatedState<T>> {
  PaginatedNotifier({
    required this.queryBuilder,
    required this.mapper,
    required this.pageSize,
    this.orderByField = 'createdAt',
  }) : super(PaginatedState<T>(isLoading: true));

  final Query<Map<String, dynamic>> Function() queryBuilder;
  final T Function(DocumentSnapshot<Map<String, dynamic>> doc) mapper;
  final int pageSize;
  final String orderByField;

  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _disposed = false;

  Future<void> fetchFirst() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snap = await queryBuilder().limit(pageSize).get();
      _lastDoc = snap.docs.isEmpty ? null : snap.docs.last;
      state = PaginatedState<T>(
        items: snap.docs.map(mapper).toList(),
        hasMore: snap.docs.length == pageSize,
      );
    } catch (e) {
      logWarning('paginated fetch failed', error: e, tag: 'page');
      state = state.copyWith(isLoading: false, error: mapExceptionToFailure(e));
    }
  }

  Future<void> fetchNext() async {
    if (_disposed) return;
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final query = _lastDoc == null
          ? queryBuilder().limit(pageSize)
          : queryBuilder().startAfterDocument(_lastDoc!).limit(pageSize);
      final snap = await query.get();
      _lastDoc = snap.docs.isEmpty ? null : snap.docs.last;
      final newItems = snap.docs.map(mapper).toList();
      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == pageSize,
      );
    } catch (e) {
      logWarning('paginated fetchMore failed', error: e, tag: 'page');
      state = state.copyWith(isLoadingMore: false, error: mapExceptionToFailure(e));
    }
  }

  Future<void> refresh() async {
    _lastDoc = null;
    state = PaginatedState<T>(isLoading: true);
    await fetchFirst();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
