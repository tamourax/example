import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../../../core/widgets/custom_responsive_pair.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/attachment_picker.dart';
import '../data/request_models.dart';
import 'attachment_upload_dialog.dart';

class RequestFormDialog extends StatefulWidget {
  const RequestFormDialog({
    super.key,
    required this.onCreate,
    this.attachmentPicker = const FilePickerRequestAttachments(),
  });
  final Future<void> Function(RequestDraft) onCreate;
  final RequestAttachmentPicker attachmentPicker;

  @override
  State<RequestFormDialog> createState() => _RequestFormDialogState();
}

class _RequestFormDialogState extends State<RequestFormDialog> {
  var _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    for (final field in [
      'requestType',
      'description',
      'startDate',
      'endDate',
      'startTime',
      'endTime',
    ])
      field: TextEditingController(),
  };
  final _attachments = <RequestAttachment>[];
  bool _allDay = false;
  bool _confirming = false;
  bool _saving = false;
  bool get _busy => _confirming || _saving;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(String key) async {
    final selected = parseRequestDate(_controllers[key]!.text);
    final start = parseRequestDate(_controllers['startDate']!.text);
    final now = DateTime.now();
    final first = DateTime(1900);
    final last = DateTime(2100, 12, 31);
    var initial = selected ?? (key == 'endDate' ? start : null) ?? now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (!mounted || date == null) return;
    _controllers[key]!.text = DateFormat('yyyy-MM-dd').format(date);
    _formKey.currentState?.validate();
  }

  Future<void> _pickTime(String key) async {
    final minutes = parseRequestTime(_controllers[key]!.text);
    final time = await showTimePicker(
      context: context,
      initialTime: minutes == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (!mounted || time == null) return;
    _controllers[key]!.text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    _formKey.currentState?.validate();
  }

  String? _dateValidator(String? value, {bool end = false}) {
    final date = parseRequestDate(value ?? '');
    if (date == null) return context.l10n.invalidRequestDate;
    final start = parseRequestDate(_controllers['startDate']!.text);
    if (end && start != null && date.isBefore(start)) {
      return context.l10n.endDateBeforeStart;
    }
    return null;
  }

  String? _timeValidator(String? value, {bool end = false}) {
    final time = parseRequestTime(value ?? '');
    if (time == null) return context.l10n.invalidRequestTime;
    if (end) {
      final startDate = parseRequestDate(_controllers['startDate']!.text);
      final endDate = parseRequestDate(_controllers['endDate']!.text);
      final startTime = parseRequestTime(_controllers['startTime']!.text);
      if (startDate != null &&
          startDate == endDate &&
          startTime != null &&
          time < startTime) {
        return context.l10n.endTimeBeforeStart;
      }
    }
    return null;
  }

  Future<void> _attach() async {
    if (_attachments.length >= RequestAttachment.maxCount) {
      setState(() => _error = context.l10n.attachmentTooMany);
      return;
    }
    final files = await showDialog<List<RequestAttachment>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttachmentUploadDialog(
        picker: widget.attachmentPicker,
        remaining: RequestAttachment.maxCount - _attachments.length,
      ),
    );
    if (!mounted || files == null) return;
    setState(() {
      _attachments.addAll(files);
      _error = null;
    });
  }

  void _discard() {
    FocusScope.of(context).unfocus();
    for (final controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _formKey = GlobalKey<FormState>();
      _allDay = false;
      _attachments.clear();
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final draft = RequestDraft(
      type: _controllers['requestType']!.text,
      description: _controllers['description']!.text,
      startDate: parseRequestDate(_controllers['startDate']!.text)!,
      endDate: parseRequestDate(_controllers['endDate']!.text)!,
      allDay: _allDay,
      startTime: _allDay ? null : _controllers['startTime']!.text,
      endTime: _allDay ? null : _controllers['endTime']!.text,
      attachments: _attachments,
    );
    setState(() {
      _confirming = true;
      _error = null;
    });
    final confirmed = await AppDialog.confirm(
      context,
      title: context.l10n.creatingRequest,
      message: context.l10n.confirmNewRequest,
    );
    if (!mounted) return;
    if (!confirmed) {
      setState(() => _confirming = false);
      return;
    }
    setState(() {
      _confirming = false;
      _saving = true;
    });
    try {
      await widget.onCreate(draft);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final code = AppFailure.from(error).code;
      setState(() {
        _saving = false;
        _error = switch (code) {
          'permission-denied' ||
          'unauthorized' ||
          'unauthenticated' => context.l10n.requestSaveDenied,
          'storage-unavailable' ||
          'bucket-not-found' ||
          'project-not-found' => context.l10n.requestStorageUnavailable,
          _ => context.l10n.requestSaveFailed,
        };
      });
    }
  }

  Widget _field(
    String key,
    String label, {
    String? hint,
    FormFieldValidator<String>? validator,
    Widget? suffix,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboard,
  }) => CustomTextField(
    key: ValueKey(key),
    label: label,
    hintText: hint ?? context.l10n.textHere,
    controller: _controllers[key],
    isRequired: true,
    enabled: !_busy,
    maxLines: maxLines,
    maxLength: maxLength,
    validator: validator,
    suffixIcon: suffix,
    keyboardType: keyboard,
  );

  Widget _dateField(String key, String label) => _field(
    key,
    label,
    hint: 'YYYY-MM-DD',
    keyboard: TextInputType.datetime,
    validator: (value) => _dateValidator(value, end: key == 'endDate'),
    suffix: IconButton(
      tooltip: context.l10n.chooseDate,
      onPressed: _busy ? null : () => _pickDate(key),
      icon: const Icon(
        Icons.calendar_month_outlined,
        size: 20,
        color: AppColors.hintTextColor,
      ),
    ),
  );

  Widget _timeField(String key, String label) => _field(
    key,
    label,
    hint: 'HH:mm',
    keyboard: TextInputType.datetime,
    validator: (value) => _timeValidator(value, end: key == 'endTime'),
    suffix: IconButton(
      tooltip: context.l10n.chooseTime,
      onPressed: _busy ? null : () => _pickTime(key),
      icon: const Icon(
        Icons.schedule,
        size: 20,
        color: AppColors.hintTextColor,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Dialog(
      backgroundColor: const Color(0xFFF5F5F5),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 850,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(context.l10n.trackingTime, style: _heading),
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.hintTextColor,
                          ),
                          Text(
                            context.l10n.creatingRequestType,
                            style: _heading,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.discard,
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field('requestType', context.l10n.requestType),
                      const SizedBox(height: 16),
                      _field(
                        'description',
                        context.l10n.requestDescription,
                        maxLines: 4,
                        maxLength: 500,
                        keyboard: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      CustomResponsivePair(
                        first: _dateField('startDate', context.l10n.startDate),
                        second: _dateField('endDate', context.l10n.endDate),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SizedBox(
                          width: 350,
                          child: CustomSwitch(
                            key: const ValueKey('allDay'),
                            label: context.l10n.allDay,
                            value: _allDay,
                            onChanged: _busy
                                ? null
                                : (value) => setState(() => _allDay = value),
                          ),
                        ),
                      ),
                      if (!_allDay) ...[
                        const SizedBox(height: 16),
                        CustomResponsivePair(
                          first: _timeField(
                            'startTime',
                            context.l10n.startTime,
                          ),
                          second: _timeField('endTime', context.l10n.endTime),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.l10n.requestAttachments,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          CustomSecondaryButton(
                            label: context.l10n.upload,
                            expand: false,
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 18,
                            ),
                            onPressed: _busy ? null : _attach,
                          ),
                        ],
                      ),
                      for (var index = 0; index < _attachments.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _attachmentTile(index),
                        ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      key: const ValueKey('requestError'),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 150,
                        child: CustomSecondaryButton(
                          label: context.l10n.discard,
                          onPressed: _busy ? null : _discard,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: SizedBox(
                        width: 150,
                        child: CustomMainButton(
                          label: context.l10n.submit,
                          isLoading: _saving,
                          onPressed: _confirming ? null : _submit,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _attachmentTile(int index) {
    final file = _attachments[index];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.only(start: 8),
        leading: file.isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  file.bytes,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
                ),
              )
            : const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.hintTextColor,
              ),
        title: Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        ),
        subtitle: Text(
          '${(file.bytes.length / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: AppColors.hintTextColor,
          ),
        ),
        trailing: IconButton(
          tooltip: context.l10n.removeAttachment,
          onPressed: _busy
              ? null
              : () => setState(() => _attachments.removeAt(index)),
          icon: const Icon(Icons.cancel, size: 18, color: AppColors.red),
        ),
      ),
    );
  }

  static const _heading = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
}
