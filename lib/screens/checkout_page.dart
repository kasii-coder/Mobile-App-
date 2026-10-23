import 'package:flutter/material.dart';

import '../models/game.dart';
import 'receipt_page.dart';

const Color checkoutDarkBg = Color(0xFF171923);
const Color checkoutDarkAccent = Color(0xFFE8F38B);
const Color checkoutDarkPanel = Color(0xFF232633);

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.game, this.isLightMode});

  final Game game;
  final bool? isLightMode;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _version = 'Digital';
  String _paymentMethod = 'UPI';
  int _quantity = 1;

  // Demo delivery fee for physical discs.
  static const int deliveryFee = 99;

  bool get _isDisc => _version == 'Physical Disc';

  int get _subtotal => widget.game.price * _quantity;

  int get _delivery => _isDisc ? deliveryFee : 0;

  int get _total => _subtotal + _delivery;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _placeDemoOrder({
    required Color panelBg,
    required Color accentColor,
    required Color textColor,
    required Color subtextColor,
    required Color pageBg,
    required bool light,
  }) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptPage(
          game: widget.game,
          version: _version,
          quantity: _quantity,
          paymentMethod: _paymentMethod,
          subtotal: _subtotal,
          deliveryFee: _delivery,
          totalAmount: _total,
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          customerAddress: _addressController.text.trim(),
          customerCity: _cityController.text.trim(),
          customerPincode: _pincodeController.text.trim(),
          purchaseDate: DateTime.now(),
          isLightMode: light,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light =
        widget.isLightMode ??
        (Theme.of(context).brightness == Brightness.light);
    final pageBg = light ? const Color(0xFFF4F7FB) : checkoutDarkBg;
    final panelBg = light ? Colors.white : checkoutDarkPanel;
    final textColor = light ? const Color(0xFF0F172A) : Colors.white;
    final subtextColor = light ? const Color(0xFF64748B) : Colors.white60;
    final accentColor = light ? const Color(0xFF0284C7) : checkoutDarkAccent;
    final borderColor = light ? const Color(0xFFE2E8F0) : Colors.white12;
    final inputFill = light ? const Color(0xFFF8FAFC) : panelBg;

    final isFree = widget.game.price == 0;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        foregroundColor: textColor,
        title: Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            // Game summary
            _sectionTitle('YOUR GAME', subtextColor),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.game.imageUrl,
                      width: 95,
                      height: 115,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 95,
                        height: 115,
                        color: pageBg,
                        child: Icon(
                          Icons.videogame_asset,
                          color: accentColor,
                          size: 36,
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
                          widget.game.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${widget.game.platform} • ${widget.game.genre}',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isFree ? 'Free to play' : '₹${widget.game.price}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle('1. CHOOSE YOUR VERSION', subtextColor),

            _versionTile(
              title: 'Physical Disc',
              subtitle: 'Disc delivered to your address',
              icon: Icons.album_outlined,
              value: 'Physical Disc',
              panelBg: panelBg,
              accentColor: accentColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            const SizedBox(height: 10),
            _versionTile(
              title: 'Digital Version',
              subtitle: 'Digital download or redeemable code',
              icon: Icons.download_for_offline_outlined,
              value: 'Digital',
              panelBg: panelBg,
              accentColor: accentColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            if (_isDisc) ...[
              const SizedBox(height: 24),
              _sectionTitle('2. DELIVERY DETAILS', subtextColor),
              _input(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
                inputFill: inputFill,
                accentColor: accentColor,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
              _input(
                controller: _phoneController,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFill: inputFill,
                accentColor: accentColor,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              _input(
                controller: _addressController,
                label: 'House / street address',
                icon: Icons.location_on_outlined,
                inputFill: inputFill,
                accentColor: accentColor,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
              _input(
                controller: _cityController,
                label: 'City / state',
                icon: Icons.location_city_outlined,
                inputFill: inputFill,
                accentColor: accentColor,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
              _input(
                controller: _pincodeController,
                label: 'PIN code',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                inputFill: inputFill,
                accentColor: accentColor,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
                    return 'Enter a valid 6-digit PIN code';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            _sectionTitle(
              _isDisc ? '3. PAYMENT METHOD' : '2. PAYMENT METHOD',
              subtextColor,
            ),

            _paymentTile(
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, BHIM',
              icon: Icons.account_balance_wallet_outlined,
              value: 'UPI',
              panelBg: panelBg,
              accentColor: accentColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            _paymentTile(
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard and supported cards',
              icon: Icons.credit_card_outlined,
              value: 'Card',
              panelBg: panelBg,
              accentColor: accentColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            _paymentTile(
              title: 'Net Banking',
              subtitle: 'Pay through your bank',
              icon: Icons.account_balance_outlined,
              value: 'Net Banking',
              panelBg: panelBg,
              accentColor: accentColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: 24),

            _sectionTitle('ORDER SUMMARY', subtextColor),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    'Game price',
                    '₹$_subtotal',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    'Delivery',
                    _delivery == 0 ? 'FREE' : '₹$_delivery',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(
                    'Quantity',
                    '$_quantity',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accentColor: accentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: borderColor),
                  ),
                  _summaryRow(
                    'Total amount',
                    '₹$_total',
                    isTotal: true,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Quantity selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: panelBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: Icon(Icons.remove_circle_outline, color: textColor),
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < 5
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: Icon(Icons.add_circle_outline, color: accentColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _placeDemoOrder(
                  panelBg: panelBg,
                  accentColor: accentColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  pageBg: pageBg,
                  light: light,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: light ? Colors.white : pageBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.lock_outline),
                label: Text(
                  'PLACE ORDER • ₹$_total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Demo checkout only. Payment methods are displayed for UI '
              'purposes; no payment is processed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtextColor, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          color: subtextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _versionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color panelBg,
    required Color accentColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final selected = _version == value;

    return InkWell(
      onTap: () {
        setState(() {
          _version = value;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? accentColor : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accentColor : subtextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color panelBg,
    required Color accentColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final selected = _paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? accentColor : borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: subtextColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accentColor : subtextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color inputFill,
    required Color accentColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: accentColor),
          filled: true,
          fillColor: inputFill,
          labelStyle: TextStyle(color: subtextColor),
          errorStyle: const TextStyle(color: Colors.redAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isTotal = false,
    required Color textColor,
    required Color subtextColor,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isTotal ? textColor : subtextColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? accentColor : textColor,
            fontWeight: FontWeight.w800,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }
}
