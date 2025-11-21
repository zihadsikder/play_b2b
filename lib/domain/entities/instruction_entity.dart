class InstructionEntity {
  final String type;
  final String name;
  final PlaylistData data;

  InstructionEntity({
    required this.type,
    required this.name,
    required this.data,
  });
}

class PlaylistData {
  final String playlistRepeat;
  final List<PlaylistItem> playlist;

  PlaylistData({
    required this.playlistRepeat,
    required this.playlist,
  });
}

class PlaylistItem {
  final String folder;
  final List<String> files;
  final int adId;
  final int repeat;
  final int sequence;

  PlaylistItem({
    required this.folder,
    required this.files,
    required this.adId,
    required this.repeat,
    required this.sequence,
  });
}
