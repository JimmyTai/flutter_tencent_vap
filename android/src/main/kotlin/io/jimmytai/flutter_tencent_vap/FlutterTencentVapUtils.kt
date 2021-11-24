package io.jimmytai.flutter_tencent_vap

import com.tencent.qgame.animplayer.util.ScaleType

object FlutterTencentVapUtils {

    fun parseVapViewAlignment(alignment: String): VapViewAlignment {
        return when (alignment) {
            "top" -> VapViewAlignment.TOP
            "center" -> VapViewAlignment.CENTER
            "bottom" -> VapViewAlignment.BOTTOM
            else -> VapViewAlignment.CENTER
        }
    }

    fun parseContentMode(contentMode: String): TencentVapContentMode {
        return when (contentMode) {
            "fill" -> TencentVapContentMode.Fill
            "contain" -> TencentVapContentMode.Contain
            "cover" -> TencentVapContentMode.Cover
            else -> TencentVapContentMode.Cover
        }
    }

    fun convertContentModeToVap(contentMode: TencentVapContentMode): ScaleType {
        return when(contentMode) {
            TencentVapContentMode.Fill -> ScaleType.FIT_XY
            TencentVapContentMode.Contain -> ScaleType.FIT_CENTER
            TencentVapContentMode.Cover -> ScaleType.CENTER_CROP
        }
    }
}