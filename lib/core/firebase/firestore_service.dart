import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/app_failure.dart';

typedef Json = Map<String, dynamic>;

class FirestorePage {
  const FirestorePage({
    required this.documents,
    required this.hasMore,
    this.cursor,
  });
  final List<QueryDocumentSnapshot<Json>> documents;
  final bool hasMore;
  final DocumentSnapshot<Json>? cursor;
}

/// Firestore equivalents: GET=get/list, POST=post, PUT=put, PATCH=patch, DELETE=delete.
class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      throw AppFailure.from(error);
    }
  }

  Future<Json?> get(String collection, String id) => _guard(
    () async => (await _db.collection(collection).doc(id).get()).data(),
  );

  Future<List<QueryDocumentSnapshot<Json>>> list(
    String collection, {
    int limit = 20,
  }) => _guard(
    () async => (await _db.collection(collection).limit(limit).get()).docs,
  );

  Future<String> post(String collection, Json data) =>
      _guard(() async => (await _db.collection(collection).add(data)).id);

  /// Creates a document and writes its generated ID into its `id` field.
  Future<String> postWithId(String collection, Json data) => _guard(() async {
    final document = _db.collection(collection).doc();
    await document.set({...data, 'id': document.id});
    return document.id;
  });

  /// Replaces the document (or creates it). Use patch for a partial update.
  Future<void> put(String collection, String id, Json data) =>
      _guard(() => _db.collection(collection).doc(id).set(data));

  Future<void> patch(String collection, String id, Json data) =>
      _guard(() => _db.collection(collection).doc(id).update(data));

  Future<void> delete(String collection, String id) =>
      _guard(() => _db.collection(collection).doc(id).delete());

  Stream<DocumentSnapshot<Json>> watch(String collection, String id) =>
      _db.collection(collection).doc(id).snapshots();

  Stream<QuerySnapshot<Json>> watchCollection(String collection) =>
      _db.collection(collection).snapshots();

  /// Cursor pagination; the order field must exist on every document.
  Future<FirestorePage> page(
    String collection, {
    String orderBy = '__name__',
    int pageSize = 20,
    DocumentSnapshot<Json>? after,
    bool descending = false,
  }) {
    if (pageSize < 1) throw ArgumentError.value(pageSize, 'pageSize');
    return _guard(() async {
      Query<Json> query = _db
          .collection(collection)
          .orderBy(orderBy, descending: descending);
      if (after != null) query = query.startAfterDocument(after);
      final snapshot = await query.limit(pageSize + 1).get();
      final documents = snapshot.docs.take(pageSize).toList(growable: false);
      return FirestorePage(
        documents: documents,
        hasMore: snapshot.docs.length > pageSize,
        cursor: documents.isEmpty ? null : documents.last,
      );
    });
  }
}
