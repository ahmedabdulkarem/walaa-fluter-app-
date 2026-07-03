import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/detachment_tag_repository.dart';

final detachmentTagRepoProvider = Provider<DetachmentTagRepository>((ref) {
  return DetachmentTagRepository();
});

final specialtiesProvider = StreamProvider<List<String>>((ref) {
  return ref
      .watch(detachmentTagRepoProvider)
      .watchTagsByType('specialty')
      .map((tags) => tags.map((t) => t.value).toList());
});

final rolesProvider = StreamProvider<List<String>>((ref) async* {
  final repo = ref.watch(detachmentTagRepoProvider);
  await repo.ensureDefaultRoles();
  yield* repo
      .watchTagsByType('role')
      .map((tags) => tags.map((t) => t.value).toList());
});
