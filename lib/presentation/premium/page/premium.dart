import 'package:ben_kimim/common/widget/alert/secret_dialog.dart';
import 'package:ben_kimim/data/app_purchase/model/product_model.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:ben_kimim/presentation/premium/bloc/load_products_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/load_products_state.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_counter_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_status_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_status_state.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_state.dart';
import 'package:ben_kimim/presentation/premium/bloc/selected_plan_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/unlock_premium.dart';
import 'package:ben_kimim/presentation/premium/page/premium_info.dart';
import 'package:ben_kimim/core/configs/legal_urls.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  String _normalizeId(String productId) => productId.split(':').first;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoadProductsCubit()..loadProducts()),
        BlocProvider(create: (context) => SelectedPlanCubit()),
        BlocProvider(create: (context) => PremiumCounterCubit()),
      ],
      child: BlocBuilder<PremiumStatusCubit, PremiumStatusState>(
        builder: (context, state) {
          final unlock = context.watch<UnlockPremiumCubit>().state;

          if (state is PremiumActive || unlock == true) {
            final productsState = context.read<LoadProductsCubit>().state;

            ProductModel? product;
            PurchaseModel? purchase;

            if (state is PremiumActive) {
              purchase = state.purchase;

              if (productsState is LoadProductsSuccess &&
                  productsState.products.isNotEmpty) {
                product = productsState.products.firstWhere(
                  (p) =>
                      _normalizeId(p.productId) ==
                      _normalizeId(state.purchase.productId),
                  orElse: () => productsState.products.first,
                );
              } else {
                product = null;
              }
            } else {
              product = ProductModel(
                productId: "test_premium",
                title: "Test Premium",
                description: "Google Play inceleme modu için test ürünü",
                price: "₺0,00",
                rawPrice: 0.0,
              );

              purchase = PurchaseModel(
                productId: "test_premium",
                isActive: true,
                purchaseDate: DateTime.now(),
                isSubscription: true,
              );
            }

            return PremiumInfoPage(
              purchase: purchase,
              product: product,
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _HeaderSection(),
                            SizedBox(height: 16.h),
                            const _FeaturesSection(),
                            SizedBox(height: 20.h),
                            Text(
                              'Plan seçin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            const _PlansSection(),
                            SizedBox(height: 18.h),
                            const _LegalLinksCard(),
                            SizedBox(height: 14.h),
                            const _PaymentInfoText(),
                            SizedBox(height: 12.h),
                            const _StartButton(),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- HEADER ---------------- */

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            final counterCubit = context.read<PremiumCounterCubit>();
            counterCubit.increment();
            if (counterCubit.state >= 8) {
              counterCubit.reset();
              SecretDialog.showSecretDialog(context);
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: Icon(
            Icons.workspace_premium,
            color: AppColors.primary,
            size: 72.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tahmin Et VIP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child:         Text(
            'Hizmet: Tahmin Et VIP — otomatik yenilenen abonelik. Her dönemde: tüm destelere erişim ve reklamsız kullanım.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.35,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------- FEATURES ---------------- */

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _FeatureRow(icon: Icons.style, text: "Tüm desteleri oyna"),
        SizedBox(height: 6),
        _FeatureRow(icon: Icons.block, text: "Tüm reklamları kaldır"),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24.sp),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 18.sp)),
        SizedBox(width: 10.w),
        Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
      ],
    );
  }
}

/* ---------------- PLANS ---------------- */

class _PlansSection extends StatelessWidget {
  const _PlansSection();

  /// Google Play aylık kart: eski fiyat = güncel / (1 - bu). Örn. 60 TL, %50 → 120 TL.
  static const double _androidMonthlyMarketingDiscountFraction = 0.50;

  String _normalizeId(String productId) => productId.split(':').first;

  ProductModel _findProduct(List<ProductModel> products, String baseProductId) {
    return products.firstWhere(
      (p) => _normalizeId(p.productId) == baseProductId,
    );
  }

  String _getTitle(String productId) {
    switch (_normalizeId(productId)) {
      case 'weekly_premium':
        return 'Haftalık Üyelik';
      case 'monthly_premium':
        return 'Aylık Üyelik';
      case 'yearly_premium':
        return 'Yıllık Üyelik';
      default:
        return '';
    }
  }

  /// App Store 3.1.2(c): abonelik başlığı mümkünse mağazadaki IAP adıyla aynı olmalı.
  String _subscriptionDisplayTitle(ProductModel p) {
    final fromStore = p.title.trim();
    if (fromStore.isNotEmpty) return fromStore;
    return _getTitle(p.productId);
  }

  /// Apple 3.1.2: abonelik süresi açıkça (hafta/ay/yıl).
  String _periodLine(String productId) {
    switch (_normalizeId(productId)) {
      case 'weekly_premium':
        return 'Süre: 1 hafta · otomatik yenilenir';
      case 'monthly_premium':
        return 'Süre: 1 ay · otomatik yenilenir';
      case 'yearly_premium':
        return 'Süre: 1 yıl · otomatik yenilenir';
      default:
        return '';
    }
  }

  String? _yearlyPerMonthLine(ProductModel yearly) {
    if (yearly.rawPrice <= 0) return null;
    final perMonth = yearly.rawPrice / 12.0;
    final s = _formatMoneyLikePriceString(yearly.price, perMonth);
    return 'Yaklaşık $s / ay';
  }

  /// Pazarlama indirim yüzdesi (kart rozetleri).
  String _discountBadge({
    required ProductModel current,
    required double referenceRawPrice,
  }) {
    if (referenceRawPrice <= 0 || current.rawPrice <= 0) return '';
    if (referenceRawPrice <= current.rawPrice) return '';

    final ratio = 1 - (current.rawPrice / referenceRawPrice);
    final percent = (ratio * 100).round();
    if (percent < 5) return '';
    return '%$percent';
  }

  /// Eski fiyat = güncel ham fiyat / (1 - indirimOranı); biçim mağaza `price` string'ine yaklaştırılır.
  String? _strikethroughPriceForPlan(
    ProductModel product,
    double discountFraction,
  ) {
    if (discountFraction <= 0 || discountFraction >= 1) return null;
    if (product.rawPrice <= 0) return null;
    final oldRaw = product.rawPrice / (1.0 - discountFraction);
    return _formatMoneyLikePriceString(product.price, oldRaw);
  }

  String? _monthlyOldPriceTextForPlatform(ProductModel monthly) {
    if (monthly.rawPrice <= 0) return null;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _strikethroughPriceForPlan(
        monthly,
        _androidMonthlyMarketingDiscountFraction,
      );
    }
    return _strikethroughPriceForPlan(monthly, 0.40);
  }

  String _formatMoneyLikePriceString(String templatePrice, double value) {
    final t = templatePrice.trim();
    if (t.contains('₺')) {
      final p = value.toStringAsFixed(2).split('.');
      return '₺${p[0]},${p[1]}';
    }
    final upper = t.toUpperCase();
    if (upper.contains('TRY')) {
      return 'TRY ${value.toStringAsFixed(2)}';
    }
    if (t.startsWith(r'$')) {
      return r'$' + value.toStringAsFixed(2);
    }
    if (t.contains('€')) {
      return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadProductsCubit, LoadProductsState>(
      builder: (context, state) {
        if (state is LoadProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LoadProductsFailure) {
          return Center(child: Text("Hata: ${state.message}"));
        }
        if (state is LoadProductsSuccess) {
          final products = state.products;
          final selectedProductId = context.watch<SelectedPlanCubit>().state;
          final isPurchasing =
              context.watch<PurchaseCubit>().state is PurchaseInProgress;

          final weekly = _findProduct(products, 'weekly_premium');
          final monthly = _findProduct(products, 'monthly_premium');
          final yearly = _findProduct(products, 'yearly_premium');

          final weeklyPriceText = weekly.price;
          final monthlyPriceText = monthly.price;
          final yearlyPriceText = yearly.price;

          // Sabit pazarlama indirim yüzdeleri + üstü çizili "eski fiyat" (ham fiyata göre).
          final weeklyOldPriceText = _strikethroughPriceForPlan(weekly, 0.25);
          final monthlyOldPriceText = _monthlyOldPriceTextForPlatform(monthly);
          final yearlyOldPriceText = _strikethroughPriceForPlan(yearly, 0.50);

          final isAndroid = !kIsWeb &&
              defaultTargetPlatform == TargetPlatform.android;

          final weeklyDiscount = _discountBadge(
            current: weekly,
            referenceRawPrice: monthly.rawPrice / 4,
          );
          final monthlyDiscount = isAndroid
              ? _discountBadge(
                  current: monthly,
                  referenceRawPrice: monthly.rawPrice /
                      (1.0 - _androidMonthlyMarketingDiscountFraction),
                )
              : _discountBadge(
                  current: monthly,
                  referenceRawPrice: weekly.rawPrice * 4,
                );
          final yearlyUnit = _yearlyPerMonthLine(yearly);
          return Column(
            children: [
              PlanTile(
                title: _subscriptionDisplayTitle(weekly),
                periodLine: _periodLine(weekly.productId),
                unitPriceLine: null,
                price: weeklyPriceText,
                oldPrice: weeklyOldPriceText,
                discountPercentage:
                    weeklyDiscount.isNotEmpty ? weeklyDiscount : '%25',
                selected: selectedProductId == weekly.productId,
                onTap: () {
                  if (!isPurchasing) {
                    context
                        .read<SelectedPlanCubit>()
                        .selectPlan(weekly.productId);
                  }
                },
              ),
              PlanTile(
                title: _subscriptionDisplayTitle(monthly),
                periodLine: _periodLine(monthly.productId),
                unitPriceLine: null,
                price: monthlyPriceText,
                oldPrice: monthlyOldPriceText,
                discountPercentage: monthlyDiscount.isNotEmpty
                    ? monthlyDiscount
                    : (isAndroid ? '%50' : '%40'),
                selected: selectedProductId == monthly.productId,
                onTap: () {
                  if (!isPurchasing) {
                    context
                        .read<SelectedPlanCubit>()
                        .selectPlan(monthly.productId);
                  }
                },
              ),
              PlanTile(
                title: _subscriptionDisplayTitle(yearly),
                periodLine: _periodLine(yearly.productId),
                unitPriceLine: yearlyUnit,
                price: yearlyPriceText,
                oldPrice: yearlyOldPriceText,
                discountPercentage: '%50',
                selected: selectedProductId == yearly.productId,
                onTap: () {
                  if (!isPurchasing) {
                    context
                        .read<SelectedPlanCubit>()
                        .selectPlan(yearly.productId);
                  }
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/* ---------------- PLAN TILE ---------------- */

class PlanTile extends StatelessWidget {
  final String title;
  final String periodLine;
  final String? unitPriceLine;
  final String price;
  final String? oldPrice;
  final String discountPercentage;
  final bool selected;
  final VoidCallback onTap;

  const PlanTile({
    super.key,
    required this.title,
    required this.periodLine,
    this.unitPriceLine,
    required this.price,
    required this.discountPercentage,
    required this.onTap,
    this.oldPrice,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.grey.shade300,
                width: selected ? 2.w : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        periodLine,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.25,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: discountPercentage.isNotEmpty ? 22.h : 0,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (oldPrice != null && oldPrice!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Text(
                                oldPrice!,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            price,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (unitPriceLine != null &&
                              unitPriceLine!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              unitPriceLine!,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (discountPercentage.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14.r),
                    bottomLeft: Radius.circular(14.r),
                  ),
                ),
                child: Text(
                  discountPercentage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ---------------- LEGAL (satın alma öncesi) ---------------- */

class _LegalLinksCard extends StatelessWidget {
  const _LegalLinksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_outlined, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Gizlilik Politikası ve Kullanım Şartları (EULA)',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Satın almadan önce belgeleri açabilirsiniz. Kullanım Şartları (EULA); lisans, abonelik ve mağaza koşullarını içerir.',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.35,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _LegalLinkButton(
                  label: 'Gizlilik Politikası',
                  url: LegalUrls.privacyPolicy,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _LegalLinkButton(
                  label: 'Kullanım Şartları (EULA)',
                  url: LegalUrls.termsOfUse,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalLinkButton extends StatelessWidget {
  final String label;
  final String url;

  const _LegalLinkButton({required this.label, required this.url});

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- PAYMENT INFO ---------------- */

class _PaymentInfoText extends StatelessWidget {
  const _PaymentInfoText();

  @override
  Widget build(BuildContext context) {
    return Text(
      "Fiyatlar App Store veya Google Play’de görünen güncel tutardır. Satın alma onayından sonra ödeme hesabınızdan tahsil edilir. Abonelik, seçtiğiniz dönem sonunda otomatik yenilenir; iptal ve yönetim için mağaza hesabınızı kullanın.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13.sp, height: 1.4, color: Colors.grey.shade800),
    );
  }
}

/* ---------------- BUTTON ---------------- */

class _StartButton extends StatefulWidget {
  const _StartButton();

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, state) {
        final isLoading = state is PurchaseInProgress;

        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Transform.scale(
              scale: isLoading ? 1 : _pulse.value,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.60,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final selectedProductId =
                              context.read<SelectedPlanCubit>().state;
                          if (selectedProductId != null) {
                            context
                                .read<PurchaseCubit>()
                                .purchaseProduct(selectedProductId);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 24.sp,
                          width: 24.sp,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Şimdi Başla",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
