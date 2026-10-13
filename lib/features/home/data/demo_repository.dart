import '../../../core/pagination/pagination_state.dart';

/// Replace with REST or Firestore without changing list widgets.
class DemoRepository {
  Future<PageResult<int>> getPage(int page, int pageSize) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    const total = 53;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, total);
    return PageResult(
      items: [for (var i = start; i < end; i++) i + 1],
      hasMore: end < total,
    );
  }
}
