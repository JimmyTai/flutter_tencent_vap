class VapPlayException implements Exception {
  const VapPlayException.playResourceUnsupported()
      : code = 'invalid_resource',
        message = 'Please use AssetVapVideoResource or FileVapVideoResource';
  const VapPlayException.fromNative({required this.code, this.message = ''});
  const VapPlayException.unknown(): code = 'unknown', message = 'Meet a unknown exception, please check document';

  final String code;
  final String message;

  @override
  String toString() => 'VapPlayException -> code: $code: $message';
}
