import 'package:flutter/foundation.dart';
import 'package:flutter_tencent_vap/flutter_tencent_vap.dart';

enum PlayMessageType { asset, file }

class PlayMessage {
  const PlayMessage({
    required this.type,
    required this.path,
    required this.alignment,
    required this.contentMode,
    required this.repeat,
  });

  final PlayMessageType type;
  final String path;
  final VapViewAlignment alignment;
  final VapViewContentMode contentMode;
  final int repeat;

  Map<String, dynamic> toMap() => {
        'resource_type': describeEnum(type),
        'path': path,
        'alignment': describeEnum(alignment),
        'content_mode': describeEnum(contentMode),
        'repeat': repeat,
      };
}

class StopMessage {
  const StopMessage();

  Map<String, dynamic> toMap() => {};
}

class PauseMessage {
  const PauseMessage();

  Map<String, dynamic> toMap() => {};
}

class ResumeMessage {
  const ResumeMessage();

  Map<String, dynamic> toMap() => {};
}
