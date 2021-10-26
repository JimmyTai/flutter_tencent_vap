class VapVideoResource {
  const VapVideoResource({
    required this.path,
  });

  final String path;
}

class AssetVapVideoResource extends VapVideoResource {
  AssetVapVideoResource(String asset) : super(path: asset);
}

class FileVapVideoResource extends VapVideoResource {
  FileVapVideoResource(String path) : super(path: path);
}
