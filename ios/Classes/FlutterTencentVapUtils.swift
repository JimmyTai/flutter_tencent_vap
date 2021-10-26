
class FlutterTencentVapUtils {
  public static func parseContentMode(contentMode: String) -> TencentVapContentMode {
    switch contentMode {
    case "fill":
      return .fill
    case "contain":
      return .contain
    case "cover":
      return .cover
    default:
      return .cover
    }
  }
}
