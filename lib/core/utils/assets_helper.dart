

import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';
class AssetHelper {
  // Check if a specific asset exists
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate playlist assets
  static Future<Map<String, Object>> validatePlaylistAssets(
      List<String> videoPath,
      ) async {
    final Map<String, Object> results = {
      'total': videoPath.length,
      'found': 0,
      'missing': <String>[],
    };

    for (final path in videoPath) {
      final exists = await assetExists(path);

      if (exists) {
        results['found'] = (results['found'] as int) + 1;
      } else {
        (results['missing'] as List<String>).add(path);
      }
    }

    return results;
  }


  // Log asset diagnostics
  static Future<void> logAssetDiagnostics(List<String> videoPath) async {
    AppLogger.log('=== ASSET DIAGNOSTICS ===');
    final validation = await validatePlaylistAssets(videoPath);

    AppLogger.log('Total videos in playlist: ${validation['total']}');
    AppLogger.log('Found: ${validation['found']}');
    //AppLogger.log('Missing: ${validation['missing'].length}');

    if ((validation['missing'] as List).isNotEmpty) {
      AppLogger.error('Missing video files:');
      for (final missing in validation['missing'] as List<String>) {
        AppLogger.error('  - $missing');
      }
    }
    AppLogger.log('========================');
  }
}
