import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'streaming_service.dart';

final streamingServiceProvider = Provider<StreamingService>((ref) {
  final service = StreamingService();
  ref.onDispose(service.dispose);
  return service;
});
