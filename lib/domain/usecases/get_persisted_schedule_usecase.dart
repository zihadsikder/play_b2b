import '../../data/repositories/schedule_repository.dart';
import '../entities/instruction_entity.dart';

class GetPersistedScheduleUseCase {
  final ScheduleRepository repository;

  GetPersistedScheduleUseCase(this.repository);

  Future<List<InstructionEntity>?> call() async {
    return await repository.getPersistedSchedule();
  }
}
