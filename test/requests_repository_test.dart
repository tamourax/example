import 'package:example/core/errors/app_failure.dart';
import 'package:example/core/firebase/firestore_service.dart';
import 'package:example/features/requests/data/request_models.dart';
import 'package:example/features/requests/data/requests_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'requests_test_support.dart';

class _Firestore extends Fake implements FirestoreService {
  Json? saved;
  Object? failure;
  int writes = 0;
  @override
  String newDocumentId(String collection) => 'new-request';
  @override
  Future<void> put(String collection, String id, Json data) async {
    expect(collection, 'requests');
    expect(id, 'new-request');
    writes++;
    if (failure != null) throw failure!;
    saved = data;
  }
}

class _Storage implements RequestAttachmentStorage {
  final uploaded = <String>[];
  final deleted = <String>[];
  int? failAt;
  bool failCleanup = false;
  @override
  Future<Map<String, Object?>> upload(
    String id,
    int index,
    RequestAttachment file,
  ) async {
    if (index == failAt) throw const AppFailure('upload-failed');
    final path = '$id/$index/${file.name}';
    uploaded.add(path);
    return {
      'name': file.name,
      'storagePath': path,
      'url': 'https://example.com/$path',
      'contentType': file.contentType,
      'size': file.bytes.length,
    };
  }

  @override
  Future<void> delete(String path) async {
    deleted.add(path);
    if (failCleanup) throw const AppFailure('cleanup-failed');
  }
}

RequestDraft _draft({
  List<RequestAttachment> attachments = const [],
  bool allDay = true,
  String? startTime,
  String? endTime,
  DateTime? end,
}) => RequestDraft(
  type: ' Sick Leave ',
  description: ' Medical appointment ',
  startDate: DateTime(2026, 10, 14),
  endDate: end ?? DateTime(2026, 10, 14),
  allDay: allDay,
  startTime: startTime,
  endTime: endTime,
  attachments: attachments,
);

void main() {
  test('date parsing rejects impossible and malformed dates', () {
    expect(parseRequestDate('2026-02-29'), isNull);
    expect(parseRequestDate('2026-13-01'), isNull);
    expect(parseRequestDate('2026-1-4'), isNull);
    expect(parseRequestDate('2028-02-29'), DateTime(2028, 2, 29));
    expect(parseRequestTime('24:00'), isNull);
    expect(parseRequestTime('12:60'), isNull);
    expect(parseRequestTime('09:30'), 570);
  });

  test('all-day ignores time fields; dates and timed intervals validate', () {
    expect(
      () => _draft(startTime: 'invalid', endTime: 'invalid').validate(),
      returnsNormally,
    );
    expect(
      _draft(startTime: '09:00', endTime: '10:00').toFields()['startTime'],
      isNull,
    );
    expect(
      () => _draft(end: DateTime(2026, 10, 13)).validate(),
      throwsArgumentError,
    );
    expect(() => _draft(allDay: false).validate(), throwsArgumentError);
    expect(
      () => _draft(
        allDay: false,
        startTime: '10:00',
        endTime: '09:00',
      ).validate(),
      throwsArgumentError,
    );
    expect(
      () => _draft(
        allDay: false,
        startTime: '23:00',
        endTime: '01:00',
        end: DateTime(2026, 10, 15),
      ).validate(),
      returnsNormally,
    );
  });

  test(
    'request without attachments saves Firestore fields without Storage',
    () async {
      final firestore = _Firestore();
      await FirestoreRequestsRepository(firestore).create(_draft());
      expect(firestore.saved?['requestType'], 'Sick Leave');
      expect(firestore.saved?['id'], 'new-request');
      expect(firestore.saved?['allDay'], true);
      expect(firestore.saved?['startTime'], isNull);
      expect(firestore.saved?['attachments'], isEmpty);
      final record = RequestRecord(id: 'new-request', fields: firestore.saved!);
      expect(record.date('startDate'), DateTime.utc(2026, 10, 14));
    },
  );

  test(
    'attachment metadata is saved only after all uploads complete',
    () async {
      final firestore = _Firestore();
      final storage = _Storage();
      await FirestoreRequestsRepository(
        firestore,
        attachmentStorage: storage,
      ).create(_draft(attachments: [pdfAttachment()]));
      expect(storage.uploaded, ['new-request/0/document.pdf']);
      expect(storage.deleted, isEmpty);
      final metadata = (firestore.saved!['attachments'] as List).single as Map;
      expect(metadata['contentType'], 'application/pdf');
      expect(metadata['url'], 'https://example.com/new-request/0/document.pdf');
      expect(metadata.containsKey('bytes'), false);
    },
  );

  test(
    'failed second upload cleans first file and never writes Firestore',
    () async {
      final firestore = _Firestore();
      final storage = _Storage()..failAt = 1;
      await expectLater(
        FirestoreRequestsRepository(
          firestore,
          attachmentStorage: storage,
        ).create(
          _draft(attachments: [pdfAttachment('a.pdf'), pdfAttachment('b.pdf')]),
        ),
        throwsA(
          isA<AppFailure>().having(
            (error) => error.code,
            'code',
            'upload-failed',
          ),
        ),
      );
      expect(firestore.writes, 0);
      expect(storage.deleted, ['new-request/0/a.pdf']);
    },
  );

  test(
    'failed Firestore write cleans uploaded files and preserves original error',
    () async {
      final firestore = _Firestore()
        ..failure = const AppFailure('permission-denied');
      final storage = _Storage()..failCleanup = true;
      await expectLater(
        FirestoreRequestsRepository(
          firestore,
          attachmentStorage: storage,
        ).create(_draft(attachments: [pdfAttachment()])),
        throwsA(
          isA<AppFailure>().having(
            (error) => error.code,
            'code',
            'permission-denied',
          ),
        ),
      );
      expect(storage.deleted, ['new-request/0/document.pdf']);
    },
  );

  test('missing Storage and invalid requests cannot create records', () async {
    final firestore = _Firestore();
    final repository = FirestoreRequestsRepository(firestore);
    await expectLater(
      repository.create(_draft(attachments: [pdfAttachment()])),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          'storage-unavailable',
        ),
      ),
    );
    await expectLater(
      repository.create(_draft(end: DateTime(2026, 10, 13))),
      throwsArgumentError,
    );
    expect(firestore.writes, 0);
  });
}
