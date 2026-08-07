import 'package:ben_kimim/core/usecase/usecase.dart';
import 'package:ben_kimim/domain/rate_app/rate_prompt_policy.dart';
import 'package:ben_kimim/domain/rate_app/repository/rate_app_repository.dart';
import 'package:ben_kimim/service_locator.dart';

class RecordGameCompletedUseCase implements UseCase<void, void> {
  @override
  Future<void> call({void params}) {
    return sl<RateAppRepository>().incrementGamesCompleted();
  }
}

class ShouldShowRatePromptUseCase implements UseCase<bool, bool> {
  /// [params] = force
  @override
  Future<bool> call({bool? params}) async {
    final force = params ?? false;
    final repo = sl<RateAppRepository>();
    final didRate = await repo.hasRated();
    final games = await repo.getGamesCompleted();
    final lastPrompt = await repo.getLastPromptAt();
    return RatePromptPolicy.shouldShow(
      didRate: didRate,
      gamesCompleted: games,
      lastPromptAt: lastPrompt,
      now: DateTime.now(),
      force: force,
    );
  }
}

class MarkRatePromptDismissedUseCase implements UseCase<void, void> {
  @override
  Future<void> call({void params}) {
    return sl<RateAppRepository>().markPromptDismissed(DateTime.now());
  }
}

class MarkAppRatedUseCase implements UseCase<void, void> {
  @override
  Future<void> call({void params}) {
    return sl<RateAppRepository>().markRated();
  }
}
