import 'package:file_picker/file_picker.dart';
import 'request_models.dart';

abstract interface class RequestAttachmentPicker {
  Future<List<RequestAttachment>> pick();
}

class FilePickerRequestAttachments implements RequestAttachmentPicker {
  const FilePickerRequestAttachments();
  @override
  Future<List<RequestAttachment>> pick() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: RequestAttachment.extensions,
    );
    if (files.length > RequestAttachment.maxCount)
      throw AttachmentFailure.tooMany;
    final attachments = <RequestAttachment>[];
    for (final file in files) {
      if (await file.length() > RequestAttachment.maxBytes)
        throw AttachmentFailure.tooLarge;
      attachments.add(
        RequestAttachment.fromBytes(file.name, await file.readAsBytes()),
      );
    }
    return attachments;
  }
}
