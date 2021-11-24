import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tencent_vap/tencent_vap_exception.dart';
import 'package:flutter_tencent_vap/tencent_vap_message.dart';
import 'package:flutter_tencent_vap/tencent_vap_video_resource.dart';

export 'tencent_vap_video_resource.dart';
export 'tencent_vap_exception.dart';

enum VapViewAlignment { top, center, bottom }

enum VapViewContentMode { fill, contain, cover }

enum VapControllerStatus { init, idle, playing, pause }

class VapController {
  static const String tag = 'VapController';

  VapController();

  bool _isDisposed = false;
  Completer<void> _initializeCompleter = Completer();
  MethodChannel? _channel;
  VapControllerStatus _status = VapControllerStatus.init;
  final List<VoidCallback> _listeners = [];

  bool get isDisposed => _isDisposed;
  bool get isInitialized => _initializeCompleter.isCompleted;
  VapControllerStatus get status => _status;

  void dispose() {
    _isDisposed = true;
    removeAllListener();
  }

  Future<void> initialize() => _initializeCompleter.future;

  void _setViewId({required int id}) {
    _channel = MethodChannel('flutter_tencent_vap_$id');
    _channel!.setMethodCallHandler(_onMethodCalled);
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void removeAllListener() {
    _listeners.clear();
  }

  void _notifyListeners() {
    for (final VoidCallback listener in _listeners) {
      listener.call();
    }
  }

  void _setStatus({required VapControllerStatus status}) {
    _status = status;
    _notifyListeners();
  }

  Future<dynamic> _onMethodCalled(MethodCall call) async {
    switch (call.method) {
      case 'player_status_on_start':
        _setStatus(status: VapControllerStatus.playing);
        break;
      case 'player_status_on_stop':
        _setStatus(status: VapControllerStatus.idle);
        break;
      case 'player_status_on_pause':
        _setStatus(status: VapControllerStatus.pause);
        break;
      case 'player_status_on_resume':
        _setStatus(status: VapControllerStatus.playing);
        break;
    }
  }

  /// Don't play video in initState. It should be play after UI laid out.
  Future<void> play({
    required VapVideoResource resource,
    VapViewAlignment alignment = VapViewAlignment.center,
    VapViewContentMode contentMode = VapViewContentMode.cover,
    int repeat = 0,
  }) async {
    await _initializeCompleter.future;
    if (resource is! AssetVapVideoResource && resource is! FileVapVideoResource)
      throw VapPlayException.playResourceUnsupported();
    try {
      bool? result;
      if (resource is AssetVapVideoResource) {
        result = await _channel!.invokeMethod<bool?>(
            'play',
            PlayMessage(
              type: PlayMessageType.asset,
              path: resource.path,
              alignment: alignment,
              contentMode: contentMode,
              repeat: repeat,
            ).toMap());
      } else if (resource is FileVapVideoResource) {
        result = await _channel!.invokeMethod<bool?>(
            'play',
            PlayMessage(
              type: PlayMessageType.file,
              path: resource.path,
              alignment: alignment,
              contentMode: contentMode,
              repeat: repeat,
            ).toMap());
      }
      if (result == true) {
        return;
      }
    } on PlatformException catch (e) {
      throw VapPlayException.fromNative(code: e.code, message: e.details);
    }
    throw VapPlayException.unknown();
  }

  Future<void> stop() async {
    await _initializeCompleter.future;
    _channel!.invokeMethod('stop', StopMessage().toMap());
  }

  Future<void> pause() async {
    if (!io.Platform.isIOS) {
      /// Android 暫時不支持
      return;
    }
    await _initializeCompleter.future;
    _channel!.invokeMethod('pause', PauseMessage().toMap());
  }

  Future<void> resume() async {
    if (!io.Platform.isIOS) {
      /// Android 暫時不支持
      return;
    }
    await _initializeCompleter.future;
    _channel!.invokeMethod('resume', ResumeMessage().toMap());
  }
}

class VapView extends StatelessWidget {
  const VapView({Key? key, required this.controller}) : super(key: key);

  final VapController controller;

  void _onPlatformViewCreated(int id) {
    controller._setViewId(id: id);
    controller._setStatus(status: VapControllerStatus.idle);
    controller._initializeCompleter.complete();
  }

  @override
  Widget build(BuildContext context) {
    if (io.Platform.isAndroid) {
      final Map<String, dynamic> creationParams = <String, dynamic>{};
      return AndroidView(
        viewType: "flutter_tencent_vap",
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (io.Platform.isIOS) {
      final Map<String, dynamic> creationParams = <String, dynamic>{};
      return UiKitView(
        viewType: "flutter_tencent_vap",
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Container();
  }
}
