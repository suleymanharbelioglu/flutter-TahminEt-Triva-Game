class RatePromptPolicy {
  static const int minCompletedGamesToPrompt = 3;
  static const Duration repromptAfter = Duration(days: 7);

  static bool shouldShow({
    required bool didRate,
    required int gamesCompleted,
    required DateTime? lastPromptAt,
    required DateTime now,
    required bool force,
  }) {
    if (didRate) return false;
    if (force) return true;
    if (gamesCompleted < minCompletedGamesToPrompt) return false;
    if (lastPromptAt != null &&
        now.difference(lastPromptAt) < repromptAfter) {
      return false;
    }
    return true;
  }
}
