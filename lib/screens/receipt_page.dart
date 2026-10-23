import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({
    super.key,
    required this.game,
    required this.version,
    required this.quantity,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.customerCity,
    this.customerPincode,
    required this.purchaseDate,
    this.isLightMode,
  });

  final Game game;
  final String version;
  final int quantity;
  final String paymentMethod;
  final int subtotal;
  final int deliveryFee;
  final int totalAmount;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? customerCity;
  final String? customerPincode;
  final DateTime purchaseDate;
  final bool? isLightMode;

  bool get isDisc => version == 'Physical Disc';

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $month ${dt.year}, $hour:$minute $ampm';
  }

  String _generateOrderNumber() {
    final seed = (game.title.hashCode.abs() % 89999) + 10000;
    return 'GV-$seed';
  }

  String _generateActivationKey() {
    final code = game.id.toUpperCase().padRight(4, 'X').substring(0, 4);
    return '$code-89W2-PQ14-7L09';
  }

  @override
  Widget build(BuildContext context) {
    final light =
        isLightMode ?? (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : Colors.black;
    final panelBg = light ? Colors.white : const Color(0xFF1E212B);
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF64748B) : Colors.white70;
    final accentColor =
        light ? const Color(0xFF0284C7) : const Color(0xFF7DD3FC);
    final borderColor = light ? const Color(0xFFE2E8F0) : const Color(0xFF2E3342);

    final orderId = _generateOrderNumber();
    final formattedDate = _formatDate(purchaseDate);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textColor,
        title: Text(
          'Order Receipt',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close and Return to Store',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: Icon(Icons.close, color: textColor),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          children: [
            // Success header icon and title
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 46,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                'Thank you for your order. Here is your official purchase receipt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: subtextColor),
              ),
            ),

            const SizedBox(height: 24),

            // Receipt ticket card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: light
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER NUMBER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderId,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PAID',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Purchased on $formattedDate',
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: borderColor),
                  ),

                  // Game details item
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          game.imageUrl,
                          width: 70,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 70,
                            height: 85,
                            color: borderColor,
                            child: Icon(
                              Icons.videogame_asset,
                              color: accentColor,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${game.platform} • ${game.genre}',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isDisc ? 'Physical Disc Edition' : 'Digital Edition',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Qty: $quantity × ₹${game.price}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: borderColor),
                  ),

                  // Activation Key or Delivery Address
                  if (!isDisc) ...[
                    Text(
                      'DIGITAL ACTIVATION KEY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: light
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF141720),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.vpn_key_outlined,
                              size: 20, color: accentColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _generateActivationKey(),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy activation key',
                            icon: Icon(Icons.copy, size: 18, color: accentColor),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _generateActivationKey()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Activation key copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Redeem this key in your GameVault account or launcher to install.',
                      style: TextStyle(fontSize: 11, color: subtextColor),
                    ),
                  ] else ...[
                    Text(
                      'SHIPPING DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: light
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFF141720),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_shipping_outlined,
                                  size: 18, color: accentColor),
                              const SizedBox(width: 8),
                              Text(
                                customerName?.isNotEmpty == true
                                    ? customerName!
                                    : 'Registered Gamer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            customerAddress?.isNotEmpty == true
                                ? '${customerAddress!}, ${customerCity ?? ''} - ${customerPincode ?? ''}'
                                : 'Standard Home Delivery',
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                          if (customerPhone?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Phone: $customerPhone',
                              style: TextStyle(fontSize: 12, color: subtextColor),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                'Estimated delivery: 3 to 5 business days',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: borderColor),
                  ),

                  // Financial Breakdown
                  Text(
                    'PAYMENT SUMMARY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _receiptRow('Payment Method', paymentMethod, textColor, subtextColor),
                  const SizedBox(height: 8),
                  _receiptRow('Items Subtotal', '₹$subtotal', textColor, subtextColor),
                  const SizedBox(height: 8),
                  _receiptRow(
                    'Delivery Fee',
                    deliveryFee == 0 ? 'FREE' : '₹$deliveryFee',
                    textColor,
                    subtextColor,
                  ),
                  const SizedBox(height: 8),
                  _receiptRow('Taxes & Licensing', 'Included', textColor, subtextColor),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: borderColor),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '₹$totalAmount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: light ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.storefront),
                label: const Text(
                  'BACK TO STORE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Receipt $orderId downloaded as PDF!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.download),
                label: const Text('DOWNLOAD RECEIPT (PDF)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value,
    Color textColor,
    Color subtextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subtextColor, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
