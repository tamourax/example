import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum AttachmentFailure { unsupported, tooLarge, empty, tooMany, unreadable }

class RequestAttachment {
  RequestAttachment._(this.name, this.bytes, this.contentType);
  static const maxBytes = 10 * 1024 * 1024;
  static const maxCount = 5;
  static const extensions = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'pdf'];
  final String name;
  final Uint8List bytes;
  final String contentType;
  bool get isImage => contentType.startsWith('image/');

  factory RequestAttachment.fromBytes(String name, Uint8List bytes) {
    if (bytes.isEmpty) throw AttachmentFailure.empty;
    if (bytes.length > maxBytes) throw AttachmentFailure.tooLarge;
    final extension = name.split('.').last.toLowerCase();
    bool starts(List<int> header) =>
        bytes.length >= header.length &&
        List.generate(
          header.length,
          (i) => bytes[i] == header[i],
        ).every((v) => v);
    final contentType = switch (extension) {
      'png' when starts([137, 80, 78, 71, 13, 10, 26, 10]) => 'image/png',
      'jpg' || 'jpeg' when starts([255, 216, 255]) => 'image/jpeg',
      'gif'
          when starts([71, 73, 70, 56, 55, 97]) ||
              starts([71, 73, 70, 56, 57, 97]) =>
        'image/gif',
      'bmp' when starts([66, 77]) => 'image/bmp',
      'webp'
          when starts([82, 73, 70, 70]) &&
              bytes.length >= 12 &&
              String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP' =>
        'image/webp',
      'pdf' when starts([37, 80, 68, 70, 45]) => 'application/pdf',
      _ => throw AttachmentFailure.unsupported,
    };
    return RequestAttachment._(
      name,
      Uint8List.fromList(bytes).asUnmodifiableView(),
      contentType,
    );
  }
}

DateTime? parseRequestDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) return null;
  try {
    return DateFormat('yyyy-MM-dd').parseStrict(value.trim());
  } on FormatException {
    return null;
  }
}

int? parseRequestTime(String value) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final hours = int.parse(match[1]!);
  final minutes = int.parse(match[2]!);
  return hours < 24 && minutes < 60 ? hours * 60 + minutes : null;
}

class RequestDraft {
  RequestDraft({
    required this.type,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.allDay,
    this.startTime,
    this.endTime,
    List<RequestAttachment> attachments = const [],
  }) : attachments = List.unmodifiable(attachments);
  final String type;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool allDay;
  final String? startTime;
  final String? endTime;
  final List<RequestAttachment> attachments;

  void validate() {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (type.trim().isEmpty ||
        description.trim().isEmpty ||
        end.isBefore(start)) {
      throw ArgumentError('Invalid request fields');
    }
    if (!allDay) {
      final startMinutes = parseRequestTime(startTime ?? '');
      final endMinutes = parseRequestTime(endTime ?? '');
      if (startMinutes == null ||
          endMinutes == null ||
          (start == end && endMinutes < startMinutes)) {
        throw ArgumentError('Invalid request times');
      }
    }
    if (attachments.length > RequestAttachment.maxCount) {
      throw AttachmentFailure.tooMany;
    }
  }

  Map<String, Object?> toFields() => {
    'requestType': type.trim(),
    'description': description.trim(),
    'startDate': Timestamp.fromDate(
      DateTime.utc(startDate.year, startDate.month, startDate.day),
    ),
    'endDate': Timestamp.fromDate(
      DateTime.utc(endDate.year, endDate.month, endDate.day),
    ),
    'allDay': allDay,
    'startTime': allDay ? null : startTime!.trim(),
    'endTime': allDay ? null : endTime!.trim(),
    'status': 'submitted',
  };
}

class RequestRecord {
  RequestRecord({required this.id, required Map<String, Object?> fields})
    : fields = Map.unmodifiable(fields);
  final String id;
  final Map<String, Object?> fields;
  String text(String key) => fields[key]?.toString() ?? '';
  DateTime? date(String key) {
    final value = fields[key];
    return value is Timestamp ? value.toDate().toUtc() : null;
  }

  List<Map<String, dynamic>> get attachments =>
      (fields['attachments'] is List ? fields['attachments'] as List : const [])
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
}
