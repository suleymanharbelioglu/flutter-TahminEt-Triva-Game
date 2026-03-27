import 'package:ben_kimim/data/app_purchase/model/product_model.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumInfoPage extends StatelessWidget {
  final PurchaseModel purchase;
  final ProductModel? product;

  const PremiumInfoPage({
    super.key,
    required this.purchase,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint(
        'PremiumInfoPage: purchaseId=${purchase.productId} productId=${product?.productId} productPrice=${product?.price} platform=${Platform.operatingSystem}',
      );
    }
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 8.h),
                _buildPriceTag(),
                SizedBox(height: 25.h),
                _buildInfoCard(),
                const Spacer(),
                _buildFooterMessage(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _normalizeId(String productId) => productId.split(':').first;

  // -----------------------------------------------------------
  // BACKGROUND GRADIENT
  // -----------------------------------------------------------
  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF86D9F6), Color(0xFF0988BF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  // -----------------------------------------------------------
  // HEADER
  // -----------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.workspace_premium, size: 90.sp, color: Colors.white),
        SizedBox(height: 10.h),
        Text(
          _getTitle(purchase.productId),
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: const [
              Shadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // PRICE TAG
  // -----------------------------------------------------------
  Widget _buildPriceTag() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: FutureBuilder<String>(
        future: _resolvePriceText(purchase.productId),
        builder: (context, snapshot) {
          final text = snapshot.connectionState == ConnectionState.waiting
              ? '...'
              : (snapshot.data ?? '—');
          return Text(
            text,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          );
        },
      ),
    );
  }

  Future<String> _resolvePriceText(String productId) async {
    String canonicalBaseId(String base) {
      switch (base) {
        case 'weekly':
          return 'weekly_premium';
        case 'monthly':
          return 'monthly_premium';
        case 'yearly':
          return 'yearly_premium';
        default:
          return base;
      }
    }

    final p = product;
    if (p != null && _normalizeId(p.productId) == _normalizeId(productId)) {
      return p.price;
    }

    // Fallback: PremiumInfoPage'e product null gelebiliyor (LoadProducts henüz dolmadan).
    // Bu durumda RevenueCat offering içinden aynı baseId'li ürünü bulup fiyatı gösteriyoruz.
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) return '—';

      final base = canonicalBaseId(_normalizeId(productId));
      final match =
          offering.availablePackages.map((p) => p.storeProduct).firstWhere(
                (sp) => _normalizeId(sp.identifier) == base,
                orElse: () => offering.availablePackages.first.storeProduct,
              );
      return match.priceString;
    } catch (_) {
      if (_normalizeId(productId) == 'test_premium') return '₺0,00';
      return '—';
    }
  }

  // -----------------------------------------------------------
  // INFO CARD
  // -----------------------------------------------------------
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActiveStatus(),
          SizedBox(height: 30.h),
          _infoBulletCheck("Reklamsız uygulama kullanımı"),
          SizedBox(height: 15.h),
          _infoBulletCheck("Bütün destelere sınırsız erişim"),
          SizedBox(height: 25.h),
          _infoBulletInfo(_getRenewText(purchase.productId)),
          SizedBox(height: 15.h),
          _buildManageSubscriptionLink(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15.r,
          offset: Offset(0, 5.h),
        ),
      ],
    );
  }

  Widget _buildActiveStatus() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green, size: 28.sp),
          SizedBox(width: 10.w),
          Text(
            "Üyeliğiniz Aktif",
            style: TextStyle(
              color: Colors.green,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBulletCheck(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.orange, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBulletInfo(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info, color: Colors.blue.shade400, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManageSubscriptionLink() {
    return GestureDetector(
      onTap: _openManageSubscriptions,
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue.shade400, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(text: "Üyelik işlemlerini "),
                  TextSpan(
                    text: "Üyelik yönetimi",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(text: " üzerinden yapabilirsiniz."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openManageSubscriptions() async {
    final Uri url = Platform.isIOS
        ? Uri.parse("https://apps.apple.com/account/subscriptions")
        : Uri.parse("https://play.google.com/store/account/subscriptions");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFooterMessage() {
    return Text(
      "Üye olduğunuz için teşekkürler!",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
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
        return 'Premium Üyelik';
    }
  }

  String _getRenewText(String productId) {
    switch (_normalizeId(productId)) {
      case 'weekly_premium':
        return "Üyeliğiniz iptal edilmediği sürece haftalık olarak yenilenir.";
      case 'monthly_premium':
        return "Üyeliğiniz iptal edilmediği sürece aylık olarak yenilenir.";
      case 'yearly_premium':
        return "Üyeliğiniz iptal edilmediği sürece yıllık olarak yenilenir.";
      default:
        return "Üyeliğiniz iptal edilmediği sürece yenilenmeye devam eder.";
    }
  }
}
