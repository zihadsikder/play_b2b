
import '../../data/repositories/schedule_repository.dart';
import '../entities/instruction_entity.dart';

class LoadScheduleUseCase {
  final ScheduleRepository repository;

  LoadScheduleUseCase(this.repository);

  Future<List<InstructionEntity>> call(String jsonPath) async {
    return await repository.loadSchedule(jsonPath);
  }
}
