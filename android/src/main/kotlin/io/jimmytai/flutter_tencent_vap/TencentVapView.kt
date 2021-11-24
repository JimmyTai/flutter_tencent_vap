package io.jimmytai.flutter_tencent_vap

import android.content.Context
import android.os.Build
import android.view.View
import androidx.annotation.RequiresApi
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.inter.IAnimListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File


enum class TencentVapStatus {
    Idle, Playing, Pause
}

enum class TencentVapContentMode {
    Fill, Contain, Cover
}

class TencentVapView(val binaryMessenger: BinaryMessenger, val context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView, MethodChannel.MethodCallHandler, IAnimListener {
    private val vapView: VapView = VapView(context)
    private var channel: MethodChannel = MethodChannel(binaryMessenger, "flutter_tencent_vap_$id")

    private var playerStatus: TencentVapStatus = TencentVapStatus.Idle
    private var playResult: MethodChannel.Result? = null

    init {
        vapView.setAnimListener(this)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val params: Map<String, Any> = call.arguments as Map<String, Any>
        when (call.method) {
            "play" -> {
                val type: String = params["resource_type"] as String
                val path: String = params["path"] as String
                val alignment: String = params["alignment"] as String
                val contentMode: String = params["content_mode"] as String
                val repeatCount: Int = (params["repeat"] as Int) + 1
                play(type = type, path = path, alignment = FlutterTencentVapUtils.parseVapViewAlignment(alignment), contentMode = FlutterTencentVapUtils.parseContentMode(contentMode), repeatCount = repeatCount, result = result)
            }
            "stop" -> {
                stop()
            }
        }
    }

    private fun play(type: String, path: String, alignment: VapViewAlignment, contentMode: TencentVapContentMode, repeatCount: Int, result: MethodChannel.Result) {
        if (type != "asset" && type != "file") {
            uiThread {
                result.error("unsupported_resource_type", "Please use asset or file type", null)
            }
            return
        }
        if (playerStatus != TencentVapStatus.Idle) {
            uiThread {
                result.error("play_process_busy", "Please wait for previous playing process done.", null)
            }
            return
        }
        playerStatus = TencentVapStatus.Playing
        playResult = result
        vapView.setAlignment(alignment)
        vapView.setScaleType(FlutterTencentVapUtils.convertContentModeToVap(contentMode))
        vapView.setLoop(repeatCount)
        if (type == "asset") {
            vapView.startPlay(assetManager = context.assets, assetsPath = "flutter_assets/$path")
        } else {
            vapView.startPlay(File(path))
        }
    }

    private fun stop() {
        vapView.stopPlay()
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    override fun getView(): View {
        return vapView
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onVideoStart() {
        uiThread {
            playResult?.success(true)
            channel.invokeMethod("player_status_on_start", null)
        }
        playResult = null
    }

    override fun onFailed(errorType: Int, errorMsg: String?) {
        uiThread {
            playResult?.error("play_fail", "VAP play fail with error($errorType): $errorMsg", null)
        }
        this.playerStatus = TencentVapStatus.Idle
        this.playResult = null
    }

    override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
    }

    override fun onVideoComplete() {
    }

    override fun onVideoDestroy() {
        uiThread {
            channel.invokeMethod("player_status_on_stop", null)
        }
        this.playerStatus = TencentVapStatus.Idle
    }

    private fun uiThread(f: suspend CoroutineScope.()->Unit) {
        GlobalScope.launch(Dispatchers.Main, block = f)
    }
}