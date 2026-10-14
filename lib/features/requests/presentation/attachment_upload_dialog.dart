import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../data/attachment_picker.dart';
import '../data/request_models.dart';

String attachmentError(BuildContext context, Object error) => switch (error) {
  AttachmentFailure.tooLarge => context.l10n.attachmentTooLarge,
  AttachmentFailure.tooMany => context.l10n.attachmentTooMany,
  AttachmentFailure.unsupported ||
  AttachmentFailure.empty => context.l10n.attachmentUnsupported,
  _ => context.l10n.attachmentReadFailed,
};

class AttachmentUploadDialog extends StatefulWidget {
  const AttachmentUploadDialog({
    super.key,
    required this.picker,
    required this.remaining,
  });
  final RequestAttachmentPicker picker;
  final int remaining;

  @override
  State<AttachmentUploadDialog> createState() => _AttachmentUploadDialogState();
}

class _AttachmentUploadDialogState extends State<AttachmentUploadDialog> {
  bool _reading = false;
  bool _dragging = false;
  String? _error;

  Future<void> _read(
    Future<List<RequestAttachment>> Function() operation,
  ) async {
    if (_reading) return;
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final files = await operation();
      if (!mounted) return;
      if (files.length > widget.remaining) throw AttachmentFailure.tooMany;
      if (files.isNotEmpty) {
        Navigator.pop(context, files);
        return;
      }
    } catch (error) {
      if (mounted) setState(() => _error = attachmentError(context, error));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<List<RequestAttachment>> _droppedFiles(List<DropItem> items) async {
    if (items.length > widget.remaining) throw AttachmentFailure.tooMany;
    final files = <RequestAttachment>[];
    for (final item in items) {
      if (item is! DropItemFile) throw AttachmentFailure.unsupported;
      final bookmark = item.extraAppleBookmark;
      var hasAccess = false;
      try {
        if (bookmark != null && bookmark.isNotEmpty) {
          hasAccess = await DesktopDrop.instance
              .startAccessingSecurityScopedResource(bookmark: bookmark);
          if (!hasAccess) throw AttachmentFailure.unreadable;
        }
        if (await item.length() > RequestAttachment.maxBytes)
          throw AttachmentFailure.tooLarge;
        files.add(
          RequestAttachment.fromBytes(item.name, await item.readAsBytes()),
        );
      } finally {
        if (hasAccess) {
          await DesktopDrop.instance.stopAccessingSecurityScopedResource(
            bookmark: bookmark!,
          );
        }
      }
    }
    return files;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_reading,
    child: Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.file_upload_outlined,
                    color: AppColors.hintTextColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.addingAttachment,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropTarget(
                onDragEntered: (_) => setState(() => _dragging = true),
                onDragExited: (_) => setState(() => _dragging = false),
                onDragDone: (details) =>
                    _read(() => _droppedFiles(details.files)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _dragging ? const Color(0xFFF5F5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _dragging ? AppColors.grey : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_reading)
                        const SizedBox.square(
                          dimension: 48,
                          child: CircularProgressIndicator(
                            color: AppColors.grey,
                          ),
                        )
                      else
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 72,
                          color: AppColors.hintTextColor,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.dragDropFiles,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.attachmentLimits,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.hintTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.or,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.red,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: CustomSecondaryButton(
                      label: context.l10n.discard,
                      onPressed: _reading ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: CustomMainButton(
                      label: context.l10n.browseFiles,
                      isLoading: _reading,
                      onPressed: () => _read(widget.picker.pick),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
