import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/firebase/firestore_service.dart';

class LocationRecord {
  LocationRecord({required this.id, required Map<String, Object?> fields})
    : fields = Map.unmodifiable(fields);

  final String id;
  final Map<String, Object?> fields;

  String text(String key) => fields[key]?.toString() ?? '';
}

abstract interface class LocationsRepository {
  Stream<List<LocationRecord>> watch();
  Future<void> create(Map<String, Object?> fields);
}

class FirestoreLocationsRepository implements LocationsRepository {
  FirestoreLocationsRepository(
    this.firestore, {
    this.collection = defaultCollection,
  });

  static const defaultCollection = String.fromEnvironment(
    'LOCATIONS_COLLECTION',
    defaultValue: 'locations',
  );
  final FirestoreService firestore;
  final String collection;

  @override
  Stream<List<LocationRecord>> watch() => firestore
      .watchCollection(collection)
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  LocationRecord(id: document.id, fields: document.data()),
            )
            .toList(),
      );

  @override
  Future<void> create(Map<String, Object?> fields) async {
    await firestore.postWithId(collection, {
      ...fields,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
