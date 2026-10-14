import 'package:flutter/material.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/custom_buttons.dart';
import '../../locations/data/device_location_service.dart';
import '../../locations/data/locations_repository.dart';
import '../../locations/presentation/location_form_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.repository,
    this.deviceLocation = const GeolocatorDeviceLocationService(),
  });
  final LocationsRepository? repository;
  final DeviceLocationService deviceLocation;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<LocationRecord>> _locations = _watch();

  Stream<List<LocationRecord>> _watch() =>
      widget.repository?.watch() ?? Stream.value([]);

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _locations = _watch();
  }

  Future<void> _addLocation() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationFormDialog(
        deviceLocation: widget.deviceLocation,
        onCreate: (fields) async {
          final repository = widget.repository;
          if (repository == null) throw const AppFailure('unavailable');
          await repository.create(fields);
        },
      ),
    );
    if (!mounted || created != true) return;
    await AppSuccess.show(context);
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
                      context.l10n.locations,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CustomMainButton(
                      label: context.l10n.creatingLocations,
                      expand: false,
                      onPressed: _addLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<List<LocationRecord>>(
                    stream: _locations,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.locationsLoadFailed,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              CustomSecondaryButton(
                                label: context.l10n.retry,
                                expand: false,
                                onPressed: () =>
                                    setState(() => _locations = _watch()),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final locations = snapshot.data!;
                      if (locations.isEmpty) {
                        return Center(child: Text(context.l10n.noLocations));
                      }
                      final isArabic =
                          Localizations.localeOf(context).languageCode == 'ar';
                      return ListView.separated(
                        itemCount: locations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final name =
                              isArabic && location.text('nameAr').isNotEmpty
                              ? location.text('nameAr')
                              : location.text('nameEn');
                          final address = ['country', 'state', 'city']
                              .map(
                                (key) => location.text(
                                  '$key${isArabic ? 'Ar' : 'En'}',
                                ),
                              )
                              .where((value) => value.isNotEmpty)
                              .join(' • ');
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(name.isEmpty ? location.id : name),
                              subtitle: Text(address),
                            ),
                          );
                        },
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
}
