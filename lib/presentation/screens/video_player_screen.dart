import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_b2b/presentation/controller/video_controller.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoCtrl = Get.find<VideoController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (videoCtrl.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          );
        }

        if (videoCtrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    videoCtrl.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Check your logs to see missing video files.\nEnsure MP4 files exist in assets/videos/ads/',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: videoCtrl.videoController.value.aspectRatio,
                child: VideoPlayer(videoCtrl.videoController),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white.withOpacity(0.7),
                onPressed: videoCtrl.skipToNextVideo,
                child: const Icon(Icons.skip_next, color: Colors.black),
              ),
            ),
          ],
        );
      }),
    );
  }
}

