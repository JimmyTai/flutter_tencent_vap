package io.jimmytai.flutter_tencent_vap

import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.util.IScaleType
import io.jimmytai.flutter_tencent_vap.models.FlutterVapAlignment

class ScaleTypeFitXY : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
        realWidth = layoutWidth
        realHeight = layoutHeight
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }

}

class ScaleTypeFitCenter : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    private var alignment: FlutterVapAlignment = FlutterVapAlignment.CENTER

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getFitCenterSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        realWidth = w
        realHeight = h
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = getLayoutGravity(alignment)
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }

    fun setAlignment(alignment: FlutterVapAlignment) {
        this.alignment = alignment
    }

    private fun getFitCenterSize(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int
    ): Pair<Int, Int> {

        val layoutRatio = layoutWidth.toFloat() / layoutHeight
        val videoRatio = videoWidth.toFloat() / videoHeight

        val realWidth: Int
        val realHeight: Int
        if (layoutRatio > videoRatio) {
            realHeight = layoutHeight
            realWidth = (videoRatio * realHeight).toInt()
        } else {
            realWidth = layoutWidth
            realHeight = (realWidth / videoRatio).toInt()
        }

        return Pair(realWidth, realHeight)
    }
}

class ScaleTypeCrop : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    private var alignment: FlutterVapAlignment = FlutterVapAlignment.CENTER

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getCropSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        realWidth = w
        realHeight = h
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = getLayoutGravity(alignment)
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }

    fun setAlignment(alignment: FlutterVapAlignment) {
        this.alignment = alignment
    }

    private fun getCropSize(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int
    ): Pair<Int, Int> {

        val layoutRatio = layoutWidth.toFloat() / layoutHeight
        val videoRatio = videoWidth.toFloat() / videoHeight

        val realWidth: Int
        val realHeight: Int
        if (layoutRatio > videoRatio) {
            realWidth = layoutWidth
            realHeight = (realWidth / videoRatio).toInt()
        } else {
            realHeight = layoutHeight
            realWidth = (videoRatio * realHeight).toInt()
        }

        return Pair(realWidth, realHeight)
    }
}

fun getLayoutGravity(alignment: FlutterVapAlignment): Int {
    return when(alignment) {
        FlutterVapAlignment.TOP -> Gravity.TOP
        FlutterVapAlignment.CENTER -> Gravity.CENTER
        FlutterVapAlignment.BOTTOM -> Gravity.BOTTOM
    }
}