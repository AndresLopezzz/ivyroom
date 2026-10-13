package com.ivyroom.app

import com.google.android.gms.common.moduleinstall.InstallStatusListener
import com.google.android.gms.common.moduleinstall.ModuleInstall
import com.google.android.gms.common.moduleinstall.ModuleInstallRequest
import com.google.android.gms.common.moduleinstall.ModuleInstallStatusUpdate
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ivyroom/mlkit")
            .setMethodCallHandler { call, result ->
                if (call.method == "ensureSegmentationModel") {
                    ensureSegmentationModel { status -> result.success(status) }
                } else {
                    result.notImplemented()
                }
            }
    }

    /**
     * Pide a Play Services el modulo de recorte y avisa cuando esta listo.
     *
     * Instalada desde Play, la app lo trae de serie (meta-data en el
     * manifest). Instalada desde un APK no: Play Services lo baja "cuando
     * puede", que puede ser nunca. Pedirlo explicitamente lo baja ya.
     *
     * Responde "ready", "failed:<motivo>" o "unavailable:<motivo>".
     */
    private fun ensureSegmentationModel(reply: (String) -> Unit) {
        var replied = false
        fun once(status: String) {
            if (replied) return
            replied = true
            runOnUiThread { reply(status) }
        }

        val client = ModuleInstall.getClient(this)
        val segmenter = SubjectSegmentation.getClient(
            SubjectSegmenterOptions.Builder().enableForegroundBitmap().build()
        )

        val listener = object : InstallStatusListener {
            override fun onInstallStatusUpdated(update: ModuleInstallStatusUpdate) {
                when (update.installState) {
                    ModuleInstallStatusUpdate.InstallState.STATE_COMPLETED -> {
                        client.unregisterListener(this)
                        once("ready")
                    }
                    ModuleInstallStatusUpdate.InstallState.STATE_FAILED,
                    ModuleInstallStatusUpdate.InstallState.STATE_CANCELED -> {
                        client.unregisterListener(this)
                        once("failed:${update.errorCode}")
                    }
                    else -> {}
                }
            }
        }

        client.areModulesAvailable(segmenter)
            .addOnSuccessListener { availability ->
                if (availability.areModulesAvailable()) {
                    once("ready")
                    return@addOnSuccessListener
                }
                val request = ModuleInstallRequest.newBuilder()
                    .addApi(segmenter)
                    .setListener(listener)
                    .build()
                client.installModules(request)
                    .addOnSuccessListener { response ->
                        if (response.areModulesAlreadyInstalled()) {
                            client.unregisterListener(listener)
                            once("ready")
                        }
                        // Si no, el listener avisa al terminar la descarga.
                    }
                    .addOnFailureListener { e -> once("failed:${e.message}") }
            }
            .addOnFailureListener { e -> once("unavailable:${e.message}") }
    }
}
