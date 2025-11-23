import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


import '../../../core/utils/logger.dart';
import '../../models/instruction_model.dart';

import 'dart:isolate';


class JsonDatasource {
  static Future<List<InstructionModel>> _parseJsonInIsolate(String jsonString) async {
    final instructions = await Isolate.run(() {
      final jsonData = jsonDecode(jsonString);
      return (jsonData['instructions'] as List<dynamic>)
          .map((item) => InstructionModel.fromJson(item))
          .toList();
    });
    return instructions;
  }

  /// Load JSON from assets
  Future<List<InstructionModel>> loadFromAssets(String assetPath) async {
    try {
      AppLogger.log('Loading JSON from assets: $assetPath');
      final jsonString = await rootBundle.loadString(assetPath);

      final instructions = await _parseJsonInIsolate(jsonString);

      AppLogger.success('Loaded JSON from assets: $assetPath (${instructions.length} instructions)');
      return instructions;
    } catch (e) {
      AppLogger.error('Failed to load JSON from assets: $e');
      return [];
    }
  }

  /// Load JSON from local file
  Future<List<InstructionModel>> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.error('JSON file does not exist: $filePath');
        return [];
      }

      final jsonString = await file.readAsString();

      final instructions = await _parseJsonInIsolate(jsonString);

      AppLogger.success('Loaded JSON from file: $filePath (${instructions.length} instructions)');
      return instructions;
    } catch (e) {
      AppLogger.error('Failed to load JSON from file: $e');
      return [];
    }
  }

  /// Save JSON to local file
  Future<void> saveToFile(String fileName, List<InstructionModel> instructions) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      final jsonData = {
        'instructions': instructions.map((i) => i.toJson()).toList(),
      };

      await file.writeAsString(jsonEncode(jsonData));
      AppLogger.success('Saved JSON to file: $filePath');
    } catch (e) {
      AppLogger.error('Failed to save JSON: $e');
    }
  }

  /// Get local file path
  Future<String> getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}

