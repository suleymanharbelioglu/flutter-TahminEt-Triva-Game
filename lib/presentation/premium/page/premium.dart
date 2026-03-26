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
import 'package:flutter/material.dart';
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
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 11.h,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 13.h),
                    const _HeaderSection(),
                    SizedBox(height: 13.h),
                    const _FeaturesSection(),
                    SizedBox(height: 17.h),
                    const Expanded(child: _PlansSection()),
                    SizedBox(height: 10.h),
                    const _PaymentInfoText(),
                    SizedBox(height: 7.h),
                    const _StartButton(),
                    SizedBox(height: 10.h),
                    const _BottomLinks(),
                    SizedBox(height: 12.h),
                  ],
                ),
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
            color: Colors.orange,
            size: 80.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "VIP ÜYELİKLER",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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

          // İndirim yüzdeleri: ülke/para birimine göre mağazanın verdiği ham fiyatlarla hesaplanır.
          final weeklyDiscount = _discountBadge(
            current: weekly,
            referenceRawPrice: monthly.rawPrice / 4,
          );
          final monthlyDiscount = _discountBadge(
            current: monthly,
            referenceRawPrice: weekly.rawPrice * 4,
          );
          final yearlyDiscount = _discountBadge(
            current: yearly,
            referenceRawPrice: monthly.rawPrice * 12,
          );

          return ListView(
            children: [
              PlanTile(
                title: _getTitle(weekly.productId),
                price: weekly.price,
                discountPercentage: weeklyDiscount,
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
                title: _getTitle(monthly.productId),
                price: monthly.price,
                discountPercentage: monthlyDiscount,
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
                title: _getTitle(yearly.productId),
                price: yearly.price,
                discountPercentage: yearlyDiscount,
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
  final String price;
  final String discountPercentage;
  final bool selected;
  final VoidCallback onTap;

  const PlanTile({
    super.key,
    required this.title,
    required this.price,
    required this.discountPercentage,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected ? Colors.orange : Colors.grey.shade300,
                width: 2.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

/* ---------------- PAYMENT INFO ---------------- */

class _PaymentInfoText extends StatelessWidget {
  const _PaymentInfoText();

  @override
  Widget build(BuildContext context) {
    return Text(
      "  Satın alma onayından sonra ödeme hesabınızdan tahsil edilir. Abonelik, dönem sonunda otomatik olarak yenilenir; yenilemeyi istediğiniz zaman iptal edebilirsiniz.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14.sp),
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
                    backgroundColor: Colors.green,
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

/* ---------------- FOOTER ---------------- */

class _BottomLinks extends StatelessWidget {
  const _BottomLinks();

  @override
  Widget build(BuildContext context) {
    return const _PolicyLinks();
  }
}

class _PolicyLinks extends StatelessWidget {
  const _PolicyLinks();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LinkText(
          text: "Gizlilik Politikası",
          url:
              "https://docs.google.com/document/d/1G6uFDjzhF0GtXdVZeABFYKrQEsTZ-ZRhXvSzqsLGJqY/edit?usp=sharing",
        ),
        SizedBox(width: 20),
        _LinkText(
          text: "Kullanım Şartları",
          url:
              "https://docs.google.com/document/d/1IYbsnY3x3O1CeM2XHA_nRe97OuJXK_QP9up2aGOw_c0/edit?usp=sharing",
        ),
      ],
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final String url;

  const _LinkText({required this.text, required this.url});

  Future<void> _openLink() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLink,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
