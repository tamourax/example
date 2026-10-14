import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../data/attachment_picker.dart';
import '../data/request_models.dart';
import '../data/requests_repository.dart';
import 'request_form_dialog.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({
    super.key,
    this.repository,
    this.attachmentPicker = const FilePickerRequestAttachments(),
  });
  final RequestsRepository? repository;
  final RequestAttachmentPicker attachmentPicker;

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late Stream<List<RequestRecord>> _requests = _watch();
  Stream<List<RequestRecord>> _watch() =>
      widget.repository?.watch() ?? Stream.value([]);
  @override
  void didUpdateWidget(RequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository) _requests = _watch();
  }

  Future<void> _createRequest() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RequestFormDialog(
        attachmentPicker: widget.attachmentPicker,
        onCreate: (request) async {
          final repository = widget.repository;
          if (repository == null) throw const AppFailure('unavailable');
          await repository.create(request);
        },
      ),
    );
    if (!mounted || created != true) return;
    await AppSuccess.show(context, message: context.l10n.requestSubmitted);
  }

  Future<void> _openAttachment(Map<String, dynamic> attachment) async {
    final uri = Uri.tryParse(attachment['url']?.toString() ?? '');
    try {
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw const AppFailure('attachment-open');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.attachmentOpenFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context.l10n.requests,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    CustomMainButton(
                      label: context.l10n.submit,
                      expand: false,
                      onPressed: _createRequest,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<List<RequestRecord>>(
                    stream: _requests,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.requestsLoadFailed,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              CustomSecondaryButton(
                                label: context.l10n.retry,
                                expand: false,
                                onPressed: () =>
                                    setState(() => _requests = _watch()),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snapshot.data!;
                      if (requests.isEmpty) {
                        return Center(
                          child: Text(
                            context.l10n.noRequests,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _card(requests[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _card(RequestRecord request) {
    final start = request.date('startDate');
    final end = request.date('endDate');
    final range = [start, end]
        .whereType<DateTime>()
        .map(
          (date) => DateFormat.yMMMd(
            Localizations.localeOf(context).languageCode,
          ).format(date),
        )
        .join(' – ');
    final allDay = request.fields['allDay'] == true;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.hintTextColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.text('requestType'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.text('description'),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (range.isNotEmpty)
                  Text(
                    range,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                Text(
                  allDay
                      ? context.l10n.allDay
                      : '${request.text('startTime')} – ${request.text('endTime')}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.hintTextColor,
                  ),
                ),
              ],
            ),
            if (request.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: request.attachments
                    .map(
                      (attachment) => ActionChip(
                        avatar: Icon(
                          attachment['contentType'] == 'application/pdf'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          size: 18,
                        ),
                        label: Text(
                          attachment['name']?.toString() ??
                              context.l10n.requestAttachments,
                        ),
                        onPressed: () => _openAttachment(attachment),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
