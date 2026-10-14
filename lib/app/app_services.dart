import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/firebase/firestore_service.dart';
import '../core/network/api_client.dart';
import '../firebase_options.dart';

/// Explicit dependency injection. Access with `context.read<AppServices>()`.
class AppServices {
  AppServices({
    required this.firestore,
    required this.auth,
    this.api,
    this.storage,
  });
  final FirestoreService firestore;
  final FirebaseAuth auth;
  final ApiClient? api;
  final FirebaseStorage? storage;

  static Future<AppServices> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    // Supply tokenProvider only if your backend verifies Firebase ID tokens.
    return AppServices(
      firestore: FirestoreService(FirebaseFirestore.instance),
      auth: FirebaseAuth.instance,
      storage: FirebaseStorage.instance,
      api: baseUrl.isEmpty ? null : ApiClient(baseUrl: baseUrl),
    );
  }

  void dispose() => api?.close();
}
