import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:example/features/requests/data/attachment_picker.dart';
import 'package:example/features/requests/data/request_models.dart';
import 'package:example/features/requests/data/requests_repository.dart';

RequestAttachment pdfAttachment([String name = 'document.pdf']) =>
    RequestAttachment.fromBytes(
      name,
      Uint8List.fromList(utf8.encode('%PDF-1.7\n%%EOF')),
    );

class TestRequestPicker implements RequestAttachmentPicker {
  List<RequestAttachment> files = [pdfAttachment()];
  Object? failure;
  @override
  Future<List<RequestAttachment>> pick() async {
    if (failure != null) throw failure!;
    return files;
  }
}

class TestRequestsRepository implements RequestsRepository {
  final updates = StreamController<List<RequestRecord>>.broadcast();
  final records = <RequestRecord>[];
  RequestDraft? submitted;
  Object? failure;
  Completer<void>? pending;
  int calls = 0;

  @override
  Stream<List<RequestRecord>> watch() async* {
    yield List.of(records);
    yield* updates.stream;
  }

  @override
  Future<void> create(RequestDraft draft) async {
    draft.validate();
    calls++;
    submitted = draft;
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
    records.add(
      RequestRecord(
        id: 'request-id',
        fields: {
          ...draft.toFields(),
          'attachments': draft.attachments
              .map(
                (file) => {
                  'name': file.name,
                  'url': 'https://example.com/${file.name}',
                  'contentType': file.contentType,
                  'size': file.bytes.length,
                },
              )
              .toList(),
        },
      ),
    );
    updates.add(List.of(records));
  }
}
