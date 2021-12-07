package io.jimmytai.flutter_tencent_vap.utils

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IScaleType
import com.tencent.qgame.animplayer.util.ScaleType
import io.jimmytai.flutter_tencent_vap.ScaleTypeCrop
import io.jimmytai.flutter_tencent_vap.ScaleTypeFitCenter
import io.jimmytai.flutter_tencent_vap.ScaleTypeFitXY
import io.jimmytai.flutter_tencent_vap.models.FlutterVapAlignment

class TencentVapScaleTypeUtil {

    companion object {
        private const val TAG = "TencentVapScaleTypeUtil"
    }

    private var scaleTypeFitXY: ScaleTypeFitXY = ScaleTypeFitXY()
    private var scaleTypeFitCenter: ScaleTypeFitCenter = ScaleTypeFitCenter()
    private var scaleTypeCrop: ScaleTypeCrop = ScaleTypeCrop()

    // 動畫內容的位置
    private var alignment = FlutterVapAlignment.CENTER
    var currentScaleType = ScaleType.FIT_XY

    var scaleTypeImpl: IScaleType? = null

    var layoutWidth = 0
    var layoutHeight = 0

    var videoWidth = 0
    var videoHeight = 0


    /**
     * 获取实际视频容器宽高
     * @return w h
     */
    fun getRealSize(): Pair<Int, Int> {
        val size = getCurrentScaleType().getRealSize()
        ALog.i(TAG, "get real size (${size.first}, ${size.second})")
        return size
    }

    fun getLayoutParam(view: View?): FrameLayout.LayoutParams {
        val layoutParams = (view?.layoutParams as? FrameLayout.LayoutParams)
            ?: FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        if (!checkParams()) {
            ALog.e(
                TAG,
                "params error: layoutWidth=$layoutWidth, layoutHeight=$layoutHeight, videoWidth=$videoWidth, videoHeight=$videoHeight"
            )
            return layoutParams
        }

        return getCurrentScaleType().getLayoutParam(
            layoutWidth,
            layoutHeight,
            videoWidth,
            videoHeight,
            layoutParams
        )
    }

    private fun getCurrentScaleType(): IScaleType {
        return when (currentScaleType) {
            ScaleType.FIT_XY -> scaleTypeFitXY
            ScaleType.FIT_CENTER -> {
                scaleTypeFitCenter.setAlignment(alignment)
                scaleTypeFitCenter
            }
            ScaleType.CENTER_CROP -> {
                scaleTypeCrop.setAlignment(alignment)
                scaleTypeCrop
            }
        }
    }

    /**
     * 設置內容的位置
     */
    fun setAlignment(alignment: FlutterVapAlignment) {
        this.alignment = alignment
    }


    private fun checkParams(): Boolean {
        return layoutWidth > 0
                && layoutHeight > 0
                && videoWidth > 0
                && videoHeight > 0
    }

}