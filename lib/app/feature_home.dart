import 'package:flutter/material.dart';
import '../core/localization/l10n_extension.dart';
import '../features/home/presentation/home_page.dart';
import '../features/locations/data/locations_repository.dart';
import '../features/requests/data/requests_repository.dart';
import '../features/requests/presentation/requests_page.dart';
import 'app_services.dart';

/// Independent features share only the app's navigation and Firebase services.
class FeatureHome extends StatefulWidget {
  const FeatureHome({super.key, this.services, this.initialIndex = 0});
  final AppServices? services;
  final int initialIndex;
  @override
  State<FeatureHome> createState() => _FeatureHomeState();
}

class _FeatureHomeState extends State<FeatureHome> {
  late int _index = widget.initialIndex;
  LocationsRepository? _locations;
  RequestsRepository? _requests;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  @override
  void didUpdateWidget(FeatureHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.services != oldWidget.services) _configure();
  }

  void _configure() {
    final services = widget.services;
    _locations = services == null
        ? null
        : FirestoreLocationsRepository(services.firestore);
    _requests = services == null
        ? null
        : FirestoreRequestsRepository(
            services.firestore,
            storage: services.storage,
          );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _index == 0
        ? HomePage(repository: _locations)
        : RequestsPage(repository: _requests),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.location_on_outlined),
          label: context.l10n.locations,
        ),
        NavigationDestination(
          icon: const Icon(Icons.description_outlined),
          label: context.l10n.requests,
        ),
      ],
    ),
  );
}
