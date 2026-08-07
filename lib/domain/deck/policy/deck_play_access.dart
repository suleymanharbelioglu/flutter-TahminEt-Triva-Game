/// Deste oynama erişim kararı (saf domain kuralı).
enum DeckPlayAccess {
  canPlay,
  showVip,
  watchRewarded,
}

class DeckPlayAccessPolicy {
  static const int roundsPerAd = 2;

  static DeckPlayAccess resolve({
    required bool userIsPremium,
    required bool deckIsPremium,
    required bool deckIsAdDeck,
    required bool hasCredits,
  }) {
    if (userIsPremium) return DeckPlayAccess.canPlay;
    if (deckIsPremium) return DeckPlayAccess.showVip;
    if (deckIsAdDeck && !hasCredits) return DeckPlayAccess.watchRewarded;
    return DeckPlayAccess.canPlay;
  }
}
