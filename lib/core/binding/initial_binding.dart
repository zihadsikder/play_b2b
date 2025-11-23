import 'package:get/get.dart';
import '../../data/datasources/local/json_datasource.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../domain/usecases/get_persisted_schedule_usecase.dart';
import '../../domain/usecases/load_schedule_usecase.dart';
import '../../presentation/controller/video_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<JsonDatasource>(() => JsonDatasource());

    // Repositories
    Get.lazyPut<ScheduleRepository>(
          () => ScheduleRepository(Get.find<JsonDatasource>()),
    );

    // Use Cases
    Get.lazyPut<LoadScheduleUseCase>(
          () => LoadScheduleUseCase(Get.find<ScheduleRepository>()),
    );
    Get.lazyPut<GetPersistedScheduleUseCase>(
          () => GetPersistedScheduleUseCase(Get.find<ScheduleRepository>()),
    );

    // Controllers
    Get.put<VideoController>(
      VideoController(
        Get.find<LoadScheduleUseCase>(),
        Get.find<GetPersistedScheduleUseCase>(),
      ),
    );
  }
}
