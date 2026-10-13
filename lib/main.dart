import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'app/app_services.dart';
import 'core/logging/app_bloc_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<AppServices> _services = AppServices.initialize();
  AppServices? _resolved;

  @override
  void dispose() {
    _resolved?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppServices>(
    future: _services,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        _resolved = snapshot.data;
        return App(services: snapshot.data);
      }
      return App(
        startupFailed: snapshot.hasError,
        isStarting: !snapshot.hasError,
        onRetrySetup: () => setState(() {
          _services = AppServices.initialize();
        }),
      );
    },
  );
}
