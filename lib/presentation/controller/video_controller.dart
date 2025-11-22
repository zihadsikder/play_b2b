

import 'dart:ui';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';


import '../../core/constants/app_constants.dart';
import '../../core/utils/assets_helper.dart';
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

  VoidCallback? _videoListener;
  bool _isAutoAdvancing = false;

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


      currentInstructions =
          await loadScheduleUseCase('assets/${AppConstants.jsonFileName}');

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
      await buildPlaylist();

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

  Future<void> buildPlaylist() async {
    videoPlaylist.clear();
    final List<String> rawPlaylist = [];

    for (var instruction in currentInstructions) {
      if (instruction.type == 'update_schedule') {
        final sortedPlaylist = instruction.data.playlist.toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));

        for (var item in sortedPlaylist) {
          for (var filename in item.files) {
            final videoPath =
                '${AppConstants.videosPath}/${item.folder}/$filename';
            rawPlaylist.add(videoPath);

            for (int i = 1; i < item.repeat; i++) {
              rawPlaylist.add(videoPath);
            }
          }
        }
      }
    }

    if (rawPlaylist.isEmpty) {
      AppLogger.error('No videos found in schedule instructions');
      return;
    }

    final validation = await AssetHelper.validatePlaylistAssets(rawPlaylist);
    final missing = validation['missing'] as List<String>;

    if (missing.isNotEmpty) {
      AppLogger.error('Missing video files in playlist:');
      for (final path in missing) {
        AppLogger.error('  - $path');
      }
    }

    videoPlaylist = rawPlaylist
        .where((path) => !missing.contains(path))
        .toList();

    AppLogger.log(
      'Playlist built: ${videoPlaylist.length} videos (total: ${validation['total']}, missing: ${missing.length})',
    );
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

      await videoController.setLooping(false);
      _attachVideoListener();
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
        if (_videoListener != null) {
          videoController.removeListener(_videoListener!);
          _videoListener = null;
        }
        await videoController.dispose();
      } catch (e) {
        // Silently handle dispose errors
      }

      final nextIndex = currentVideoIndex.value + 1;
      if (nextIndex >= videoPlaylist.length) {
        // End of playlist
        final shouldLoop = _isPlaylistRepeatAlways();
        if (!shouldLoop) {
          AppLogger.log('Reached end of playlist');
          return;
        }
        currentVideoIndex.value = 0;
      } else {
        currentVideoIndex.value = nextIndex;
      }

      final nextVideoPath = videoPlaylist[currentVideoIndex.value];

      videoController = VideoPlayerController.asset(nextVideoPath);

      await videoController.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Video timeout'),
      );

      await videoController.setLooping(false);
      _attachVideoListener();
      await play();
    } catch (e) {
      AppLogger.error('Skip error: $e');
      errorMessage.value = 'Error: ${e.toString()}';
    }
  }

  bool _isPlaylistRepeatAlways() {
    for (final instruction in currentInstructions) {
      if (instruction.type == 'update_schedule') {
        // Be tolerant of different capitalizations and unknown values
        final repeat = instruction.data.playlistRepeat.toLowerCase().trim();
        return repeat == 'always';
      }
    }

    // If no explicit instruction is found, default to looping
    return true;
  }

  void _attachVideoListener() {
    _videoListener = () {
      final value = videoController.value;
      if (!value.isInitialized) return;

      // Prevent re-entrancy while we are already auto-advancing
      if (_isAutoAdvancing) return;

      final duration = value.duration;
      if (duration == Duration.zero) return;

      final position = value.position;

      // Allow a small tolerance so we still advance if the position is
      // a bit smaller than duration due to rounding.
      const tolerance = Duration(milliseconds: 500);
      final isNearEnd = position + tolerance >= duration;

      // We consider the video "ended" when it is no longer playing and the
      // current position is at (or very near) the end.
      final isAtEnd = !value.isPlaying && isNearEnd;

      if (isAtEnd) {
        _isAutoAdvancing = true;
        skipToNextVideo().whenComplete(() {
          _isAutoAdvancing = false;
        });
      }
    };

    if (_videoListener != null) {
      videoController.addListener(_videoListener!);
    }
  }

  @override
  void onClose() {
    try {
      if (_videoListener != null) {
        videoController.removeListener(_videoListener!);
        _videoListener = null;
      }
      videoController.dispose();
    } catch (e) {
      // Silently handle dispose errors
    }
    super.onClose();
  }
}

