import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/instruction_entity.dart';
import '../../domain/repositories/schedule_repository_interface.dart';
import '../datasources/local/json_datasource.dart';
import '../models/instruction_model.dart';

class ScheduleRepository implements IScheduleRepository {
  final JsonDatasource datasource;

  ScheduleRepository(this.datasource);

  @override
  Future<List<InstructionEntity>> loadSchedule(String jsonPath) async {
    try {
      List<InstructionModel> instructions;
      
      // Try to load from assets first
      if (jsonPath.startsWith('assets/')) {
        instructions = await datasource.loadFromAssets(jsonPath);
      } else {
        // Load from file system
        instructions = await datasource.loadFromFile(jsonPath);
      }

      if (instructions.isNotEmpty) {
        // Persist the loaded schedule
        await persistSchedule(instructions);
        AppLogger.success('Schedule loaded and persisted');
      }

      return instructions;
    } catch (e) {
      AppLogger.error('Error loading schedule: $e');
      // Return persisted schedule if loading fails
      return await getPersistedSchedule() ?? [];
    }
  }

  @override
  Future<void> persistSchedule(List<InstructionEntity> instructions) async {
    try {
      final models = instructions.map((i) {
        return InstructionModel(
          type: i.type,
          name: i.name,
          data: i.data,
        );
      }).toList();

      await datasource.saveToFile(AppConstants.jsonFileName, models);
      AppLogger.success('Schedule persisted locally');
    } catch (e) {
      AppLogger.error('Error persisting schedule: $e');
    }
  }

  @override
  Future<List<InstructionEntity>?> getPersistedSchedule() async {
    try {
      final filePath = await datasource.getLocalFilePath(AppConstants.jsonFileName);
      final instructions = await datasource.loadFromFile(filePath);
      
      if (instructions.isNotEmpty) {
        AppLogger.success('Retrieved persisted schedule');
        return instructions;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error retrieving persisted schedule: $e');
      return null;
    }
  }
}
