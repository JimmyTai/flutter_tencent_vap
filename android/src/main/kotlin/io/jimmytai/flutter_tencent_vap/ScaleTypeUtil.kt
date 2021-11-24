package io.jimmytai.flutter_tencent_vap

/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * Licensed under the MIT License (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IScaleType
import com.tencent.qgame.animplayer.util.ScaleType

class ScaleTypeUtil {

    companion object {
        private const val TAG = "${Constant.TAG}.ScaleTypeUtil"
    }

    private var scaleTypeFitXY: ScaleTypeFitXY = ScaleTypeFitXY()
    private var scaleTypeFitCenter: ScaleTypeFitCenter = ScaleTypeFitCenter()
    private var scaleTypeCrop: ScaleTypeCrop = ScaleTypeCrop()

    // 動畫內容的位置
    private var alignment = VapViewAlignment.CENTER
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
    fun setAlignment(alignment: VapViewAlignment) {
        this.alignment = alignment
    }


    private fun checkParams(): Boolean {
        return layoutWidth > 0
                && layoutHeight > 0
                && videoWidth > 0
                && videoHeight > 0
    }

}

fun getLayoutGravity(alignment: VapViewAlignment): Int {
    return when(alignment) {
        VapViewAlignment.TOP -> Gravity.TOP
        VapViewAlignment.CENTER -> Gravity.CENTER
        VapViewAlignment.BOTTOM -> Gravity.BOTTOM
    }
}