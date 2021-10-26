package io.jimmytai.flutter_tencent_vap

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterTencentVapPlugin */
class FlutterTencentVapPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPluginBinding.platformViewRegistry.registerViewFactory("flutter_tencent_vap", TencentVapViewFactory(flutterPluginBinding.binaryMessenger))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
