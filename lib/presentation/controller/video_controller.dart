

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';


import '../../core/utils/logger.dart';
import '../../domain/entities/instruction_entity.dart';
import '../../domain/usecases/get_persisted_schedule_usecase.dart';
import '../../domain/usecases/load_schedule_usecase.dart';


class VideoController extends GetxController {
  final LoadScheduleUseCase loadScheduleUseCase;
  final GetPersistedScheduleUseCase getPersistedScheduleUseCase;

  VideoController(this.loadScheduleUseCase, this.getPersistedScheduleUseCase);

  late VideoPlayerController videoController;
  late List<InstructionEntity> currentInstructions;
  late List<String> videoPlaylist = [];

  final isPlaying = false.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final currentVideoIndex = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      AppLogger.log('Starting app initialization');

      // Try to load from assets, fall back to persisted
      currentInstructions = await loadScheduleUseCase('assets/video_instructions.json');

      if (currentInstructions.isEmpty) {
        AppLogger.log('Checking persisted storage');
        final persisted = await getPersistedScheduleUseCase();
        if (persisted != null && persisted.isNotEmpty) {
          currentInstructions = persisted;
        } else {
          throw Exception('No schedule found');
        }
      }

      AppLogger.log('Building playlist');
      buildPlaylist();

      if (videoPlaylist.isEmpty) {
        throw Exception('Playlist is empty');
      }

      AppLogger.log('Initializing first video');
      await initializeFirstVideo();
      isLoading.value = false;
      AppLogger.success('App ready');
    } catch (e) {
      AppLogger.error('Init error: $e');
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
    }
  }

  void buildPlaylist() {
    videoPlaylist.clear();

    for (var instruction in currentInstructions) {
      if (instruction.type == 'update_schedule') {
        final sortedPlaylist = instruction.data.playlist.toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));

        for (var item in sortedPlaylist) {
          for (var filename in item.files) {
            final videoPath = 'assets/videos/${item.folder}/$filename';
            videoPlaylist.add(videoPath);

            for (int i = 1; i < item.repeat; i++) {
              videoPlaylist.add(videoPath);
            }
          }
        }
      }
    }

    // Only log summary, not individual items
    AppLogger.log('Playlist built: ${videoPlaylist.length} videos');
  }

  Future<void> initializeFirstVideo() async {
    if (videoPlaylist.isEmpty) {
      throw Exception('Playlist is empty');
    }

    try {
      final firstVideoPath = videoPlaylist[0];

      videoController = VideoPlayerController.asset(firstVideoPath);

      await videoController.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Video timeout'),
      );

      await videoController.setLooping(true);
      await play();

      AppLogger.success('Video ready');
    } catch (e) {
      AppLogger.error('Video init failed: $e');
      errorMessage.value = 'Video error: ${e.toString()}';

      if (videoPlaylist.length > 1) {
        await skipToNextVideo();
      }
    }
  }

  Future<void> play() async {
    try {
      await videoController.play();
      isPlaying.value = true;
    } catch (e) {
      AppLogger.error('Play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await videoController.pause();
      isPlaying.value = false;
    } catch (e) {
      AppLogger.error('Pause error: $e');
    }
  }

  Future<void> skipToNextVideo() async {
    try {
      try {
        await videoController.dispose();
      } catch (e) {
        // Silently handle dispose errors
      }

      currentVideoIndex.value = (currentVideoIndex.value + 1) % videoPlaylist.length;
      final nextVideoPath = videoPlaylist[currentVideoIndex.value];

      videoController = VideoPlayerController.asset(nextVideoPath);

      await videoController.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Video timeout'),
      );

      await videoController.setLooping(true);
      await play();
    } catch (e) {
      AppLogger.error('Skip error: $e');
      errorMessage.value = 'Error: ${e.toString()}';
    }
  }

  @override
  void onClose() {
    try {
      videoController.dispose();
    } catch (e) {
      // Silently handle
    }
    super.onClose();
  }
}


