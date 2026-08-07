import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/data/app_purchase/repository/purchase_repo_impl.dart';
import 'package:ben_kimim/data/app_purchase/source/revenuecat_purchase_service.dart';
import 'package:ben_kimim/data/card/repository/card_repo_impl.dart';
import 'package:ben_kimim/data/card/source/card_service.dart';
import 'package:ben_kimim/data/deck/repository/deck_repo_impl.dart';
import 'package:ben_kimim/data/deck/source/deck_service.dart';
import 'package:ben_kimim/data/rate_app/repository/rate_app_repo_impl.dart';
import 'package:ben_kimim/domain/app_purchase/repository/purchase_repository.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/get_premium_status.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/load_products.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/purchase_product.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/restore_purchases.dart';
import 'package:ben_kimim/domain/card/repository/card_repo.dart';
import 'package:ben_kimim/domain/card/usecase/get_current_card_name_list.dart';
import 'package:ben_kimim/domain/deck/repository/deck_repo.dart';
import 'package:ben_kimim/domain/rate_app/repository/rate_app_repository.dart';
import 'package:ben_kimim/domain/rate_app/usecase/rate_app_usecases.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // services
  sl.registerSingleton<AnalyticsService>(AnalyticsService());
  sl.registerSingleton<DeckService>(DeckServiceImpl());
  sl.registerSingleton<CardService>(CardServiceImpl());
  sl.registerSingleton<RevenueCatPurchaseService>(
    RevenueCatPurchaseServiceImpl(),
  );
  sl.registerSingleton<RateAppPrefsService>(RateAppPrefsServiceImpl());

  // repos
  sl.registerSingleton<DeckRepo>(DeckRepoImpl());
  sl.registerSingleton<CardRepo>(CardRepoImpl());
  sl.registerSingleton<PurchaseRepository>(PurchaseRepoImpl());
  sl.registerSingleton<RateAppRepository>(
    RateAppRepoImpl(sl<RateAppPrefsService>()),
  );

  // usecases
  sl.registerSingleton<GetCurrentCardNameListUseCase>(
    GetCurrentCardNameListUseCase(),
  );
  sl.registerSingleton<LoadProductsUseCase>(LoadProductsUseCase());
  sl.registerSingleton<PurchaseProductUseCase>(PurchaseProductUseCase());
  sl.registerSingleton<RestorePurchasesUseCase>(RestorePurchasesUseCase());
  sl.registerSingleton<GetPremiumStatusUseCase>(GetPremiumStatusUseCase());
  sl.registerSingleton<RecordGameCompletedUseCase>(
    RecordGameCompletedUseCase(),
  );
  sl.registerSingleton<ShouldShowRatePromptUseCase>(
    ShouldShowRatePromptUseCase(),
  );
  sl.registerSingleton<MarkRatePromptDismissedUseCase>(
    MarkRatePromptDismissedUseCase(),
  );
  sl.registerSingleton<MarkAppRatedUseCase>(MarkAppRatedUseCase());
}
