
import UIKit
import Flutter
import QGVAPlayer

enum TencentVapStatus {
  case idle
  case playing
  case pause
}

enum TencentVapContentMode {
  case fill
  case contain
  case cover
}

class TencentVapViewFactory: NSObject, FlutterPlatformViewFactory {
  private var registrar: FlutterPluginRegistrar
  
  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
  }
  
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    
    return TencentVapView(frame: frame, viewIdentifier: viewId, arguments: args, registrar: self.registrar)
  }
  
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class TencentVapView: NSObject, FlutterPlatformView, VAPWrapViewDelegate {
  private var registrar: FlutterPluginRegistrar
  private var channel: FlutterMethodChannel
  private var rootView: UIView
  
  private var vapView: QGVAPWrapView?
  private var contentMode: TencentVapContentMode?
  
  private var playerStatus: TencentVapStatus = .idle
  private var playResult: FlutterResult?
  
  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.channel = FlutterMethodChannel.init(name: "flutter_tencent_vap_\(viewId)", binaryMessenger: self.registrar.messenger())
    self.rootView = UIView()
    self.rootView.clipsToBounds = true
    super.init()
    self.channel.setMethodCallHandler(methodCallHandler)
    self.channel.invokeMethod("initialized", arguments: nil)
  }
  
  func methodCallHandler(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
    let params: [String: Any?]? = call.arguments as? [String: Any?]
    switch call.method {
    case "play":
      // Clear variable relate to play process
      contentMode = nil
      
      let type: String? = params?["resource_type"] as? String
      let path: String? = params?["path"] as? String
      let contentMode: String? = params?["content_mode"] as? String
      let repeatCount: Int? = params?["repeat"] as? Int
      if type == nil || path == nil || contentMode == nil || repeatCount == nil {
        result(FlutterError.init(code: "invalid_parameters", message: "Please check method channel parameters", details: nil))
        return
      }
      play(type: type!, path: path!, contentMode: FlutterTencentVapUtils.parseContentMode(contentMode: contentMode!), repeatCount: repeatCount!, result: result)
      break
    case "stop":
      stop()
      break
    case "pause":
      pause()
      break
    case "resume":
      resume()
      break
    default:
      break
    }
  }
  
  func play(type: String, path: String, contentMode: TencentVapContentMode, repeatCount: Int, result: @escaping FlutterResult) -> Void {
    var filePath: String?
    if type == "asset" {
      let assetPath: String = self.registrar.lookupKey(forAsset: path)
      filePath = Bundle.main.path(forResource: assetPath, ofType: nil)
      if filePath == nil {
        result(FlutterError.init(code: "cannot_find_asset", message: "Cannot find asset, please check your directory", details: nil))
        return
      }
    } else if type == "file" {
      filePath = path
    } else {
      result(FlutterError.init(code: "unsupported_resource_type", message: "Please use asset or file type", details: nil))
      return
    }
    
    if self.playerStatus != .idle {
      result(FlutterError.init(code: "play_process_busy", message: "Please wait for previous playing proccess done.", details: nil))
      return
    }
    
    self.playerStatus = .playing
    self.playResult = result
    
    self.vapView = QGVAPWrapView.init(frame: self.rootView.bounds)
    self.rootView.addSubview(self.vapView!)
    self.vapView!.center = self.rootView.center
    self.vapView!.autoDestoryAfterFinish = true
    
    self.contentMode = contentMode
    
    self.vapView?.playHWDMP4(filePath!, repeatCount: repeatCount, delegate: self)
  }
  
  func pause() -> Void {
    self.vapView?.pauseHWDMP4();
    self.playerStatus = .pause
    self.channel.invokeMethod("player_status_on_pause", arguments: nil)
  }
  
  func resume() -> Void {
    self.vapView?.resumeHWDMP4();
    self.playerStatus = .playing
    self.channel.invokeMethod("player_status_on_resume", arguments: nil)
  }
  
  func stop() -> Void {
    self.vapView?.stopHWDMP4()
    self.vapView = nil
    self.playerStatus = .idle
  }
  
  func vapWrap_viewshouldStartPlayMP4(_ container: UIView, config: QGVAPConfigModel) -> Bool {
    container.hwd_enterBackgroundOP = .pauseAndResume
    setupContentModeWithConfig(view: container, config: config)
    return true
  }
  
  func vapWrap_viewDidStartPlayMP4(_ container: UIView) {
    //    print("[TencentVapView] start play mp4")
    self.playResult?(true)
    self.playResult = nil
    self.channel.invokeMethod("player_status_on_start", arguments: nil)
  }
  
  func vapWrap_viewDidFailPlayMP4(_ error: Error) {
    //    print("[TencentVapView] start play mp4 with error: \(error)")
    self.playResult?(FlutterError.init(code: "play_fail", message: "VAP play fail with error: \(error)", details: nil))
    self.playerStatus = .idle
    self.playResult = nil
  }
  
  func vapWrap_viewDidStopPlayMP4(_ lastFrameIndex: Int, view container: UIView) {
    print("[TencentVapView] stop play mp4")
    self.vapView = nil
    self.playerStatus = .idle
    self.channel.invokeMethod("player_status_on_stop", arguments: nil)
  }
  
  func vapWrap_viewDidFinishPlayMP4(_ totalFrameCount: Int, view container: UIView) {
    print("[TencentVapView] finish play mp4")
  }
  
  private func setupContentModeWithConfig(view: UIView, config: QGVAPConfigModel) -> Void {
    var realWidth: CGFloat = 0.0
    var realHeight: CGFloat = 0.0
    
    let layoutWidth: CGFloat = self.rootView.bounds.size.width
    let layoutHeight: CGFloat = self.rootView.bounds.size.height
    
    let layoutRatio: CGFloat = self.rootView.bounds.width / self.rootView.bounds.height
    let videoRatio: CGFloat = config.info.size.width / config.info.size.height
    
    switch (self.contentMode) {
    case .fill:
      break
    case .contain:
      if (layoutRatio < videoRatio) {
        realWidth = layoutWidth;
        realHeight = realWidth / videoRatio;
      } else {
        realHeight = layoutHeight;
        realWidth = videoRatio * realHeight;
      }
      
      view.frame = CGRect.init(x: 0, y: 0, width: realWidth, height: realHeight)
      view.center = self.rootView.center
      break
    case .cover:
      if (layoutRatio > videoRatio) {
        realWidth = layoutWidth;
        realHeight = realWidth / videoRatio;
      } else {
        realHeight = layoutHeight;
        realWidth = videoRatio * realHeight;
      }
      
      view.frame = CGRect.init(x: 0, y: 0, width: realWidth, height: realHeight)
      view.center = self.rootView.center
      break
    default:
      break
    }
  }
  
  func view() -> UIView {
    return self.rootView
  }
}
