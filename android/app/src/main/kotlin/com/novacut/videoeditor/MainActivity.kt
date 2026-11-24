package com.novacut.videoeditor

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.novacut.videoeditor/media_engine"
    private val TAG = "NovaCutMediaEngine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "muxVideoAndAudio" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val audioPath = call.argument<String>("audioPath")
                    val outputPath = call.argument<String>("outputPath")
                    val removeOriginalAudio = call.argument<Boolean>("removeOriginalAudio") ?: false

                    if (videoPath == null || outputPath == null) {
                        result.error("INVALID_ARGS", "videoPath and outputPath required", null)
                        return@setMethodCallHandler
                    }

                    Thread {
                        try {
                            val success = processMuxing(videoPath, audioPath, outputPath, removeOriginalAudio)
                            runOnUiThread {
                                if (success) {
                                    result.success(outputPath)
                                } else {
                                    result.error("MUX_FAILED", "Failed to mux video and audio", null)
                                }
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in processMuxing", e)
                            runOnUiThread {
                                result.error("MUX_EXCEPTION", e.message, null)
                            }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun processMuxing(
        videoPath: String,
        audioPath: String?,
        outputPath: String,
        removeOriginalAudio: Boolean
    ): Boolean {
        val outputFile = File(outputPath)
        outputFile.parentFile?.mkdirs()
        if (outputFile.exists()) {
            outputFile.delete()
        }

        val videoExtractor = MediaExtractor()
        videoExtractor.setDataSource(videoPath)

        var videoTrackIndex = -1
        var originalAudioTrackIndex = -1

        for (i in 0 until videoExtractor.trackCount) {
            val format = videoExtractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
            if (mime.startsWith("video/") && videoTrackIndex == -1) {
                videoTrackIndex = i
            } else if (mime.startsWith("audio/") && originalAudioTrackIndex == -1) {
                originalAudioTrackIndex = i
            }
        }

        if (videoTrackIndex == -1) {
            videoExtractor.release()
            return false
        }

        val muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        videoExtractor.selectTrack(videoTrackIndex)
        val videoFormat = videoExtractor.getTrackFormat(videoTrackIndex)
        val muxerVideoTrack = muxer.addTrack(videoFormat)

        var audioExtractor: MediaExtractor? = null
        var audioTrackIndex = -1
        var muxerAudioTrack = -1

        if (audioPath != null && File(audioPath).exists()) {
            try {
                val tempExtractor = MediaExtractor()
                tempExtractor.setDataSource(audioPath)
                for (i in 0 until tempExtractor.trackCount) {
                    val format = tempExtractor.getTrackFormat(i)
                    val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
                    if (mime.startsWith("audio/")) {
                        try {
                            val track = muxer.addTrack(format)
                            audioTrackIndex = i
                            audioExtractor = tempExtractor
                            audioExtractor.selectTrack(i)
                            muxerAudioTrack = track
                        } catch (e: Exception) {
                            Log.w(TAG, "Muxer does not support direct audio track for $mime: ${e.message}")
                        }
                        break
                    }
                }
                if (audioExtractor == null) {
                    tempExtractor.release()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to read audio from $audioPath", e)
            }
        } else if (!removeOriginalAudio && originalAudioTrackIndex != -1) {
            try {
                videoExtractor.selectTrack(originalAudioTrackIndex)
                val audioFormat = videoExtractor.getTrackFormat(originalAudioTrackIndex)
                muxerAudioTrack = muxer.addTrack(audioFormat)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to add original audio track: ${e.message}")
            }
        }

        muxer.start()

        val bufferSize = 1024 * 1024
        val buffer = ByteBuffer.allocate(bufferSize)
        val bufferInfo = MediaCodec.BufferInfo()

        // 1. Copy Video Track samples
        while (true) {
            bufferInfo.offset = 0
            bufferInfo.size = videoExtractor.readSampleData(buffer, 0)
            if (bufferInfo.size < 0) {
                break
            }
            if (videoExtractor.sampleTrackIndex == videoTrackIndex) {
                bufferInfo.presentationTimeUs = videoExtractor.sampleTime
                bufferInfo.flags = videoExtractor.sampleFlags
                muxer.writeSampleData(muxerVideoTrack, buffer, bufferInfo)
            }
            videoExtractor.advance()
        }

        // 2. Copy Audio Track samples
        if (audioExtractor != null && audioTrackIndex != -1 && muxerAudioTrack != -1) {
            while (true) {
                bufferInfo.offset = 0
                bufferInfo.size = audioExtractor.readSampleData(buffer, 0)
                if (bufferInfo.size < 0) {
                    break
                }
                bufferInfo.presentationTimeUs = audioExtractor.sampleTime
                bufferInfo.flags = audioExtractor.sampleFlags
                muxer.writeSampleData(muxerAudioTrack, buffer, bufferInfo)
                audioExtractor.advance()
            }
            audioExtractor.release()
        } else if (!removeOriginalAudio && originalAudioTrackIndex != -1 && muxerAudioTrack != -1) {
            videoExtractor.seekTo(0, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
            while (true) {
                bufferInfo.offset = 0
                bufferInfo.size = videoExtractor.readSampleData(buffer, 0)
                if (bufferInfo.size < 0) {
                    break
                }
                if (videoExtractor.sampleTrackIndex == originalAudioTrackIndex) {
                    bufferInfo.presentationTimeUs = videoExtractor.sampleTime
                    bufferInfo.flags = videoExtractor.sampleFlags
                    muxer.writeSampleData(muxerAudioTrack, buffer, bufferInfo)
                }
                videoExtractor.advance()
            }
        }

        videoExtractor.release()
        try {
            muxer.stop()
            muxer.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping muxer", e)
        }

        return File(outputPath).exists() && File(outputPath).length() > 0
    }
}
