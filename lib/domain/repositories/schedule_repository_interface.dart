import '../entities/instruction_entity.dart';

abstract class IScheduleRepository {
  Future<List<InstructionEntity>> loadSchedule(String jsonPath);
  Future<void> persistSchedule(List<InstructionEntity> instructions);
  Future<List<InstructionEntity>?> getPersistedSchedule();
}
