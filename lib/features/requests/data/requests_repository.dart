import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/firestore_service.dart';
import 'request_models.dart';

abstract interface class RequestsRepository {
  Stream<List<RequestRecord>> watch();
  Future<void> create(RequestDraft request);
}

abstract interface class RequestAttachmentStorage {
  Future<Map<String, Object?>> upload(
    String requestId,
    int index,
    RequestAttachment file,
  );
  Future<void> delete(String path);
}

class FirebaseRequestAttachmentStorage implements RequestAttachmentStorage {
  FirebaseRequestAttachmentStorage(this.storage);
  final FirebaseStorage storage;

  @override
  Future<Map<String, Object?>> upload(
    String requestId,
    int index,
    RequestAttachment file,
  ) async {
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final ref = storage.ref('request-attachments/$requestId/$index-$safeName');
    var uploaded = false;
    try {
      await ref.putData(
        file.bytes,
        SettableMetadata(contentType: file.contentType),
      );
      uploaded = true;
      return {
        'name': file.name,
        'url': await ref.getDownloadURL(),
        'storagePath': ref.fullPath,
        'contentType': file.contentType,
        'size': file.bytes.length,
      };
    } catch (_) {
      if (uploaded) {
        try {
          await ref.delete();
        } catch (_) {
          /* Retain the upload error. */
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> delete(String path) => storage.ref(path).delete();
}

class FirestoreRequestsRepository implements RequestsRepository {
  FirestoreRequestsRepository(
    this.firestore, {
    FirebaseStorage? storage,
    RequestAttachmentStorage? attachmentStorage,
    this.collection = defaultCollection,
  }) : attachmentStorage =
           attachmentStorage ??
           (storage == null ? null : FirebaseRequestAttachmentStorage(storage));
  static const defaultCollection = String.fromEnvironment(
    'REQUESTS_COLLECTION',
    defaultValue: 'requests',
  );
  final FirestoreService firestore;
  final RequestAttachmentStorage? attachmentStorage;
  final String collection;

  @override
  Stream<List<RequestRecord>> watch() =>
      firestore.watchCollection(collection).map((snapshot) {
        final records = snapshot.docs
            .map((doc) => RequestRecord(id: doc.id, fields: doc.data()))
            .toList();
        records.sort(
          (a, b) => (b.date('createdAt') ?? DateTime(1970)).compareTo(
            a.date('createdAt') ?? DateTime(1970),
          ),
        );
        return records;
      });

  @override
  Future<void> create(RequestDraft request) async {
    request.validate();
    if (request.attachments.isNotEmpty && attachmentStorage == null) {
      throw const AppFailure('storage-unavailable');
    }
    final id = firestore.newDocumentId(collection);
    final uploaded = <String>[];
    final attachments = <Map<String, Object?>>[];
    try {
      for (var index = 0; index < request.attachments.length; index++) {
        final file = request.attachments[index];
        final metadata = await attachmentStorage!.upload(id, index, file);
        uploaded.add(metadata['storagePath']! as String);
        attachments.add(metadata);
      }
      await firestore.put(collection, id, {
        ...request.toFields(),
        'id': id,
        'createdAt': FieldValue.serverTimestamp(),
        'attachments': attachments,
      });
    } catch (error) {
      // Only assets uploaded for this failed create are eligible for cleanup.
      await Future.wait(
        uploaded.map((path) async {
          try {
            await attachmentStorage!.delete(path);
          } catch (_) {
            /* Preserve the original failure. */
          }
        }),
      );
      throw AppFailure.from(error);
    }
  }
}
