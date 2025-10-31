import 'package:flutter/material.dart';
import '../services/revenue_cat_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;
  String _selectedPlan = 'annual'; // Default to annual (best value)

  Future<void> _purchaseSelected() async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      
      switch (_selectedPlan) {
        case 'monthly':
          success = await RevenueCatService.purchaseMonthly();
          break;
        case 'annual':
          success = await RevenueCatService.purchaseAnnual();
          break;
        case 'lifetime':
          success = await RevenueCatService.purchaseLifetime();
          break;
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true); // Return true to refresh
        } else {
          _showError('Could not complete purchase. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unlock Full Access',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the plan that works for you',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Pricing Options
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Annual Plan (Best Value)
                        _buildPricingCard(
                          plan: 'annual',
                          title: 'Annual',
                          price: '\$49.99',
                          period: 'per year',
                          savings: 'BEST VALUE - Save \$10',
                          badge: 'Most Popular',
                          features: [
                            '3-day free trial',
                            '\$4.16/month when paid annually',
                          ],
                          badgeColor: Colors.green,
                          isRecommended: true,
                        ),
                        const SizedBox(height: 12),

                        // Monthly Plan
                        _buildPricingCard(
                          plan: 'monthly',
                          title: 'Monthly',
                          price: '\$4.99',
                          period: 'per month',
                          features: [
                            '3-day free trial',
                            'Cancel anytime',
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Lifetime Plan
                        _buildPricingCard(
                          plan: 'lifetime',
                          title: 'Lifetime',
                          price: '\$79.99',
                          period: 'one-time',
                          savings: 'Pay once, own forever',
                          features: [
                            'No recurring charges',
                            'Best long-term value',
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Features List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Features:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem('Unlimited custom tiles', Icons.grid_view),
                        _buildFeatureItem('Add images to any tile', Icons.image),
                        _buildFeatureItem('Create custom categories', Icons.category),
                        _buildFeatureItem('Text-to-speech input', Icons.mic),
                        _buildFeatureItem('Yes/No quick access', Icons.check_circle),
                        _buildFeatureItem('All categories unlocked', Icons.lock_open),
                        _buildFeatureItem('Priority support', Icons.support_agent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Purchase Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: _purchaseSelected,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Restore Purchases
                  TextButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        await RevenueCatService.restorePurchases();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Purchases restored successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showError('Could not restore purchases: $e');
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                    child: const Text('Restore Purchases'),
                  ),

                  const SizedBox(height: 8),

                  // Terms
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPricingCard({
    required String plan,
    required String title,
    required String price,
    required String period,
    String? savings,
    String? badge,
    required List<String> features,
    Color? badgeColor,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPlan == plan;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Radio button
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (savings != null)
                              Text(
                                savings,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isRecommended ? Colors.green : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            period,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Features
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.only(left: 36, top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            // Badge
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_selectedPlan) {
      case 'monthly':
        return 'Start 3-Day Free Trial';
      case 'annual':
        return 'Start 3-Day Free Trial';
      case 'lifetime':
        return 'Buy Lifetime Access';
      default:
        return 'Continue';
    }
  }
}