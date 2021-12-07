package io.jimmytai.flutter_tencent_vap.utils

import com.tencent.qgame.animplayer.util.ScaleType
import io.jimmytai.flutter_tencent_vap.models.FlutterVapAlignment
import io.jimmytai.flutter_tencent_vap.models.FlutterVapContentMode

object FlutterVapParameterParser {

    fun parseVapViewAlignment(alignment: String): FlutterVapAlignment {
        return when (alignment) {
            "top" -> FlutterVapAlignment.TOP
            "center" -> FlutterVapAlignment.CENTER
            "bottom" -> FlutterVapAlignment.BOTTOM
            else -> FlutterVapAlignment.CENTER
        }
    }

    fun parseContentMode(contentMode: String): FlutterVapContentMode {
        return when (contentMode) {
            "fill" -> FlutterVapContentMode.Fill
            "contain" -> FlutterVapContentMode.Contain
            "cover" -> FlutterVapContentMode.Cover
            else -> FlutterVapContentMode.Cover
        }
    }

    fun convertContentModeToVap(contentMode: FlutterVapContentMode): ScaleType {
        return when(contentMode) {
            FlutterVapContentMode.Fill -> ScaleType.FIT_XY
            FlutterVapContentMode.Contain -> ScaleType.FIT_CENTER
            FlutterVapContentMode.Cover -> ScaleType.CENTER_CROP
        }
    }
}