
class FlutterTencentVapUtils {
  public static func parseAlignment(alignment: String) -> TencentVapAlignment {
    switch alignment {
    case "top":
      return .top
    case "center":
      return .center
    case "bottom":
      return .bottom
    default:
      return .center
    }
  }
  
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
