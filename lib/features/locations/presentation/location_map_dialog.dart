import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../core/widgets/custom_buttons.dart';

class LocationMapDialog extends StatefulWidget {
  const LocationMapDialog({super.key, this.initialPosition});
  final LatLng? initialPosition;

  @override
  State<LocationMapDialog> createState() => _LocationMapDialogState();
}

class _LocationMapDialogState extends State<LocationMapDialog> {
  late LatLng? _selected = widget.initialPosition;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: SizedBox(
      width: 850,
      height: MediaQuery.sizeOf(context).height * .8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.selectOnMap,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.discard,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(context.l10n.tapMapToSelect),
            const SizedBox(height: 12),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selected ?? const LatLng(0, 0),
                  initialZoom: _selected == null ? 2 : 14,
                  onTap: (_, point) => setState(() => _selected = point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.example',
                  ),
                  if (_selected != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selected!,
                          width: 48,
                          height: 48,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_selected != null)
              Text(
                '${_selected!.latitude.toStringAsFixed(6)}, ${_selected!.longitude.toStringAsFixed(6)}',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            CustomMainButton(
              label: context.l10n.useSelectedLocation,
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
            ),
          ],
        ),
      ),
    ),
  );
}
