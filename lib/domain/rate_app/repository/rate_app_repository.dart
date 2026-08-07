abstract class RateAppRepository {
  Future<int> getGamesCompleted();
  Future<void> incrementGamesCompleted();
  Future<bool> hasRated();
  Future<void> markRated();
  Future<DateTime?> getLastPromptAt();
  Future<void> markPromptDismissed(DateTime at);
}
