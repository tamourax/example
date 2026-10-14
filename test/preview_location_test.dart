import 'dart:io';
import 'dart:ui' as ui;
import 'package:example/app/app.dart';
import 'package:example/core/widgets/app_dialog.dart';
import 'package:example/features/locations/data/device_location_service.dart';
import 'package:example/features/locations/presentation/location_form_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('render location preview', (tester) async {
    tester.view.physicalSize = const Size(1430, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fonts = FontLoader('Cairo');
    for (final weight in ['Regular', 'Medium', 'SemiBold']) {
      fonts.addFont(rootBundle.load('assets/font/cairo/Cairo-$weight.ttf'));
    }
    await fonts.load();
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: key, child: const App()));
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '${Directory.systemTemp.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('location-home-preview');
    final context = tester.element(find.byType(Scaffold));
    showDialog<void>(
      context: context,
      builder: (_) => LocationFormDialog(
        deviceLocation: _PreviewDeviceLocation(),
        onCreate: (_) async {},
      ),
    );
    await tester.pumpAndSettle();
    await capture('location-form-preview');
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    AppDialog.confirmLocation(context);
    await tester.pumpAndSettle();
    await capture('location-confirm-preview');
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    AppSuccess.show(context);
    await tester.pumpAndSettle();
    await capture('location-success-preview');
  });
}

class _PreviewDeviceLocation implements DeviceLocationService {
  @override
  Future<LatLng> currentPosition() async => const LatLng(30.0444, 31.2357);
}
