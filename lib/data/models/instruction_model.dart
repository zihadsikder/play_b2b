

import '../../domain/entities/instruction_entity.dart';

class InstructionModel extends InstructionEntity {
  InstructionModel({
    required super.type,
    required super.name,
    required super.data,
  });

  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    return InstructionModel(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      data: PlaylistDataModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'data': {
        'playlist_repeat': data.playlistRepeat,
        'playlist': data.playlist
            .map((item) => PlaylistItemModel.toJson(item))
            .toList(),
      },
    };
  }
}

class PlaylistDataModel extends PlaylistData {
  PlaylistDataModel({
    required super.playlistRepeat,
    required super.playlist,
  });

  factory PlaylistDataModel.fromJson(Map<String, dynamic> json) {
    final playlistList = (json['playlist'] as List<dynamic>? ?? [])
        .map((item) => PlaylistItemModel.fromJson(item))
        .toList();

    return PlaylistDataModel(
      playlistRepeat: json['playlist_repeat'] ?? 'always',
      playlist: playlistList,
    );
  }
}

class PlaylistItemModel extends PlaylistItem {
  PlaylistItemModel({
    required super.folder,
    required super.files,
    required super.adId,
    required super.repeat,
    required super.sequence,
  });

  factory PlaylistItemModel.fromJson(Map<String, dynamic> json) {
    return PlaylistItemModel(
      folder: json['folder'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      adId: json['ad_id'] ?? 0,
      repeat: json['repeat'] ?? 1,
      sequence: json['sequence'] ?? 1,
    );
  }

  static Map<String, dynamic> toJson(PlaylistItem item) {
    return {
      'folder': item.folder,
      'files': item.files,
      'ad_id': item.adId,
      'repeat': item.repeat,
      'sequence': item.sequence,
    };
  }
}
