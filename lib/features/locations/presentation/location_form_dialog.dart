import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/app_dialog.dart';
import '../data/device_location_service.dart';
import 'location_map_dialog.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../../../core/widgets/custom_form_section.dart';
import '../../../core/widgets/custom_responsive_pair.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../l10n/generated/app_localizations.dart';

class LocationFormDialog extends StatefulWidget {
  const LocationFormDialog({
    super.key,
    required this.onCreate,
    this.deviceLocation = const GeolocatorDeviceLocationService(),
  });
  final Future<void> Function(Map<String, Object?>) onCreate;
  final DeviceLocationService deviceLocation;
  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  var _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{
    for (final field in [
      'nameEn',
      'nameAr',
      'mapsUrl',
      'latitude',
      'longitude',
    ])
      field: TextEditingController(),
    for (final field in ['country', 'state', 'city', 'postalCode'])
      for (final language in ['En', 'Ar'])
        '$field$language': TextEditingController(),
  };
  bool _geofence = false;
  bool _breaks = false;
  bool _pause = false;
  bool _saving = false;
  bool _confirming = false;
  bool get _busy => _saving || _confirming;
  bool _locating = false;
  String? _saveError;
  DeviceLocationFailure? _locationFailure;
  int _locationRequest = 0;
  String? _generatedMapsUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _locate();
    });
  }

  Future<void> _locate() async {
    if (_locating || _busy) return;
    final request = ++_locationRequest;
    final latitudeBefore = _controllers['latitude']!.text;
    final longitudeBefore = _controllers['longitude']!.text;
    setState(() {
      _locating = true;
      _locationFailure = null;
    });
    try {
      final point = await widget.deviceLocation.currentPosition();
      if (!mounted || request != _locationRequest || _busy) return;
      // Preserve coordinates entered while the device request was pending.
      if (_controllers['latitude']!.text == latitudeBefore &&
          _controllers['longitude']!.text == longitudeBefore) {
        _fillPosition(point);
      }
    } catch (error) {
      if (!mounted || request != _locationRequest) return;
      setState(
        () => _locationFailure = error is DeviceLocationFailure
            ? error
            : DeviceLocationFailure.unavailable,
      );
    } finally {
      if (mounted && request == _locationRequest) {
        setState(() => _locating = false);
      }
    }
  }

  void _fillPosition(LatLng point) {
    _controllers['latitude']!.text = point.latitude.toStringAsFixed(6);
    _controllers['longitude']!.text = point.longitude.toStringAsFixed(6);
    if (_controllers['mapsUrl']!.text.trim().isEmpty ||
        _controllers['mapsUrl']!.text == _generatedMapsUrl) {
      _generatedMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}';
      _controllers['mapsUrl']!.text = _generatedMapsUrl!;
    }
  }

  Future<void> _pickOnMap() async {
    final latitude = double.tryParse(_controllers['latitude']!.text);
    final longitude = double.tryParse(_controllers['longitude']!.text);
    final point = await showDialog<LatLng>(
      context: context,
      builder: (_) => LocationMapDialog(
        initialPosition:
            latitude != null &&
                longitude != null &&
                latitude.isFinite &&
                longitude.isFinite &&
                latitude.abs() <= 90 &&
                longitude.abs() <= 180
            ? LatLng(latitude, longitude)
            : null,
      ),
    );
    if (!mounted || point == null) return;
    ++_locationRequest;
    setState(() {
      _locating = false;
      _locationFailure = null;
    });
    _fillPosition(point);
  }

  String _locationMessage() => switch (_locationFailure) {
    DeviceLocationFailure.denied => context.l10n.locationPermissionDenied,
    DeviceLocationFailure.deniedForever =>
      context.l10n.locationPermissionPermanent,
    DeviceLocationFailure.disabled => context.l10n.locationServicesDisabled,
    _ => context.l10n.deviceLocationUnavailable,
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _discard() {
    ++_locationRequest;
    FocusScope.of(context).unfocus();
    for (final controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _formKey = GlobalKey<FormState>();
      _geofence = false;
      _breaks = false;
      _pause = false;
      _locating = false;
      _saveError = null;
      _generatedMapsUrl = null;
    });
  }

  Future<void> _create() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _confirming = true;
      _saveError = null;
    });
    final values = <String, Object?>{
      for (final entry in _controllers.entries)
        entry.key: entry.value.text.trim(),
      'latitude': double.parse(_controllers['latitude']!.text.trim()),
      'longitude': double.parse(_controllers['longitude']!.text.trim()),
      'allowGeofence': _geofence,
      'allowBreaks': _breaks,
      'allowPause': _pause,
    };
    final confirmed = await AppDialog.confirmLocation(context);
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
      await widget.onCreate(values);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = AppFailure.from(error).code == 'permission-denied'
            ? context.l10n.locationSaveDenied
            : context.l10n.locationSaveFailed;
      });
    }
  }

  Widget _field(
    String key,
    String label, {
    bool arabic = false,
    bool isRequired = false,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Color? textColor,
  }) {
    final strings = lookupAppLocalizations(Locale(arabic ? 'ar' : 'en'));
    return Directionality(
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomTextField(
        key: ValueKey(key),
        label: label,
        controller: _controllers[key],
        hintText: strings.textHere,
        isRequired: isRequired,
        requiredErrorText: strings.fieldRequired,
        validator: validator,
        keyboardType: keyboardType,
        prefixIcon: prefixIcon,
        textColor: textColor,
        enabled: !_busy,
      ),
    );
  }

  Widget _bilingual(
    String key,
    String english,
    String arabic, {
    bool isRequired = false,
  }) => CustomResponsivePair(
    first: _field('${key}En', english, isRequired: isRequired),
    second: _field(
      '${key}Ar',
      arabic,
      arabic: true,
      isRequired: isRequired && key != 'name',
    ),
  );

  String? _coordinate(String? value, double limit) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || !number.isFinite || number.abs() > limit
        ? context.l10n.invalidCoordinate
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final english = lookupAppLocalizations(const Locale('en'));
    final arabic = lookupAppLocalizations(const Locale('ar'));
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        backgroundColor: const Color(0xFFF5F5F5),
        child: SizedBox(
          width: 1100,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _heading(strings.trackingTime),
                            Transform.flip(
                              flipX:
                                  Directionality.of(context) ==
                                  TextDirection.rtl,
                              child: const AppImage(
                                'assets/icons/arrow.svg',
                                width: 8,
                                height: 16,
                              ),
                            ),
                            _heading(strings.creatingLocation),
                            IconButton(
                              tooltip: strings.discard,
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomFormSection(
                          title: strings.locationDescription,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _bilingual(
                                'name',
                                english.locationName,
                                arabic.locationName,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                'mapsUrl',
                                strings.googleMapsLocation,
                                isRequired: true,
                                keyboardType: TextInputType.url,
                                textColor: AppColors.blue,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: AppImage(
                                    'assets/icons/Map Point.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final uri = Uri.tryParse(value.trim());
                                  return uri != null &&
                                          uri.scheme == 'https' &&
                                          (((uri.host == 'google.com' ||
                                                      uri.host.endsWith(
                                                        '.google.com',
                                                      )) &&
                                                  (uri.path == '/maps' ||
                                                      uri.path.startsWith(
                                                        '/maps/',
                                                      ))) ||
                                              uri.host == 'maps.app.goo.gl' ||
                                              (uri.host == 'goo.gl' &&
                                                  uri.path.startsWith(
                                                    '/maps/',
                                                  )))
                                      ? null
                                      : strings.invalidMapsUrl;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomResponsivePair(
                                first: _field(
                                  'latitude',
                                  strings.latitude,
                                  isRequired: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                  validator: (value) => _coordinate(value, 90),
                                ),
                                second: _field(
                                  'longitude',
                                  strings.longitude,
                                  isRequired: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                  validator: (value) => _coordinate(value, 180),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  CustomSecondaryButton(
                                    label: strings.useDeviceLocation,
                                    expand: false,
                                    isLoading: _locating,
                                    onPressed: _saving ? null : _locate,
                                  ),
                                  CustomSecondaryButton(
                                    label: strings.selectOnMap,
                                    expand: false,
                                    onPressed: _saving ? null : _pickOnMap,
                                  ),
                                ],
                              ),
                              if (_locationFailure != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _locationMessage(),
                                    style: const TextStyle(
                                      color: AppColors.hintTextColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              CustomResponsivePair(
                                first: CustomSwitch(
                                  label: strings.allowGeofence,
                                  value: _geofence,
                                  onChanged: _saving
                                      ? null
                                      : (value) =>
                                            setState(() => _geofence = value),
                                ),
                                second: const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 24),
                              _bilingual(
                                'country',
                                english.country,
                                arabic.country,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),
                              _bilingual(
                                'state',
                                english.stateProvince,
                                arabic.stateProvince,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),
                              _bilingual(
                                'city',
                                english.city,
                                arabic.city,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),
                              _bilingual(
                                'postalCode',
                                english.postalCode,
                                arabic.postalCode,
                                isRequired: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormSection(
                          title: strings.locationSetting,
                          child: CustomResponsivePair(
                            first: CustomSwitch(
                              label: strings.allowBreaks,
                              value: _breaks,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() => _breaks = value),
                            ),
                            second: CustomSwitch(
                              label: strings.allowPause,
                              value: _pause,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() => _pause = value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_saveError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _saveError!,
                              key: const ValueKey('saveError'),
                              style: const TextStyle(color: AppColors.red),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: SizedBox(
                                width: 150,
                                child: CustomSecondaryButton(
                                  label: strings.discard,
                                  onPressed: _saving ? null : _discard,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: SizedBox(
                                width: 150,
                                child: CustomMainButton(
                                  label: strings.create,
                                  onPressed: _create,
                                  isLoading: _saving,
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
          ),
        ),
      ),
    );
  }

  Widget _heading(String text) => CustomText(
    text,
    style: const TextStyle(
      fontFamily: 'Cairo',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.4,
    ),
  );
}
