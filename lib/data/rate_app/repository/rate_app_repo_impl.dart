import 'package:ben_kimim/domain/rate_app/repository/rate_app_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RateAppPrefsService {
  Future<int> getGamesCompleted();
  Future<void> incrementGamesCompleted();
  Future<bool> hasRated();
  Future<void> markRated();
  Future<DateTime?> getLastPromptAt();
  Future<void> markPromptDismissed(DateTime at);
}

class RateAppPrefsServiceImpl implements RateAppPrefsService {
  static const _kGamesCompleted = 'rate_app_games_completed';
  static const _kLastPromptMs = 'rate_app_last_prompt_ms';
  static const _kDidRate = 'rate_app_did_rate';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<int> getGamesCompleted() async {
    final prefs = await _prefs;
    return prefs.getInt(_kGamesCompleted) ?? 0;
  }

  @override
  Future<void> incrementGamesCompleted() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_kGamesCompleted) ?? 0;
    await prefs.setInt(_kGamesCompleted, current + 1);
  }

  @override
  Future<bool> hasRated() async {
    final prefs = await _prefs;
    return prefs.getBool(_kDidRate) == true;
  }

  @override
  Future<void> markRated() async {
    final prefs = await _prefs;
    await prefs.setBool(_kDidRate, true);
  }

  @override
  Future<DateTime?> getLastPromptAt() async {
    final prefs = await _prefs;
    final lastMs = prefs.getInt(_kLastPromptMs);
    if (lastMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastMs);
  }

  @override
  Future<void> markPromptDismissed(DateTime at) async {
    final prefs = await _prefs;
    await prefs.setInt(_kLastPromptMs, at.millisecondsSinceEpoch);
  }
}

class RateAppRepoImpl implements RateAppRepository {
  RateAppRepoImpl(this._source);

  final RateAppPrefsService _source;

  @override
  Future<int> getGamesCompleted() => _source.getGamesCompleted();

  @override
  Future<void> incrementGamesCompleted() => _source.incrementGamesCompleted();

  @override
  Future<bool> hasRated() => _source.hasRated();

  @override
  Future<void> markRated() => _source.markRated();

  @override
  Future<DateTime?> getLastPromptAt() => _source.getLastPromptAt();

  @override
  Future<void> markPromptDismissed(DateTime at) =>
      _source.markPromptDismissed(at);
}
