import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _androidApiKey = 'goog_bSwObNbWEtzFQQIsaTidZzrAyYD';
  static const String _iosApiKey = 'appcfaf1fd845';
  static const String _entitlementId = 'pro';

  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    
    // Use platform-specific API key
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
  }

  static Future<bool> isPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (e) {
      print('Error checking premium status: \$e');
      return false;
    }
  }

  /// Purchase Monthly Subscription (\$4.99/month with 3-day trial)
  static Future<bool> purchaseMonthly() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Find the monthly package using the standard RevenueCat identifier
        Package? monthlyPackage = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.identifier == '\$rc_monthly',
          orElse: () => offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier.contains('monthly'),
            orElse: () => throw Exception('Monthly package not found'),
          ),
        );

        CustomerInfo customerInfo = await Purchases.purchasePackage(monthlyPackage);
        return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      }
      return false;
    } catch (e) {
      print('Error purchasing monthly subscription: \$e');
      rethrow;
    }
  }

  /// Purchase Annual Subscription with 3-day trial (\$49.99/year)
  static Future<bool> purchaseAnnual() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Find the annual package with trial using the standard RevenueCat identifier
        Package? annualPackage = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.identifier == '\$rc_annual',
          orElse: () => offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier.contains('trial') || 
                     pkg.storeProduct.identifier.contains('yearly'),
            orElse: () => throw Exception('Annual package not found'),
          ),
        );

        CustomerInfo customerInfo = await Purchases.purchasePackage(annualPackage);
        return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      }
      return false;
    } catch (e) {
      print('Error purchasing annual subscription: \$e');
      rethrow;
    }
  }

  /// Purchase Lifetime Access (\$79.99 one-time)
  static Future<bool> purchaseLifetime() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Find the lifetime package using the standard RevenueCat identifier
        Package? lifetimePackage = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.identifier == '\$rc_lifetime',
          orElse: () => offerings.current!.availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier.contains('premium'),
            orElse: () => throw Exception('Lifetime package not found'),
          ),
        );

        CustomerInfo customerInfo = await Purchases.purchasePackage(lifetimePackage);
        return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      }
      return false;
    } catch (e) {
      print('Error purchasing lifetime access: \$e');
      rethrow;
    }
  }

  /// Legacy method - kept for backwards compatibility (now calls purchaseAnnual)
  @Deprecated('Use purchaseAnnual() instead')
  static Future<bool> startTrial() async {
    return purchaseAnnual();
  }

  /// Legacy method - kept for backwards compatibility (now calls purchaseLifetime)
  @Deprecated('Use purchaseLifetime() instead')
  static Future<bool> purchasePremium() async {
    return purchaseLifetime();
  }

  /// Restore previous purchases
  static Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: \$e');
      rethrow;
    }
  }

  /// Get current customer info
  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('Error getting customer info: \$e');
      rethrow;
    }
  }

  /// Get available offerings
  static Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      print('Error getting offerings: \$e');
      rethrow;
    }
  }
}
