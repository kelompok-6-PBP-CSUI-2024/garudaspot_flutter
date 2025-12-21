import 'package:flutter/material.dart';
import 'package:garudaspot_flutter/tiket/services/ticket_service.dart';

class TicketLinkForm extends StatefulWidget {
  const TicketLinkForm({
    super.key,
    required this.onSubmit,
  });

  final Future<bool> Function(TicketLinkPayload payload) onSubmit;

  @override
  State<TicketLinkForm> createState() => _TicketLinkFormState();
}

class _TicketLinkFormState extends State<TicketLinkForm> {
  final _formKey = GlobalKey<FormState>();
  final _vendorC = TextEditingController();
  final _vendorLinkC = TextEditingController();
  final _priceC = TextEditingController();
  final _imgVendorC = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _vendorC.dispose();
    _vendorLinkC.dispose();
    _priceC.dispose();
    _imgVendorC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFE11D2A);
    const primaryRedDark = Color(0xFFB91C1C);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Ticket Link',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _submitting ? null : () => Navigator.pop(context, false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(_vendorC, label: 'Vendor', validator: _required),
            _buildField(_vendorLinkC, label: 'Vendor Link', keyboardType: TextInputType.url, validator: _required),
            _buildField(_priceC, label: 'Price', keyboardType: TextInputType.number, validator: _required),
            _buildField(_imgVendorC, label: 'Vendor Image URL', keyboardType: TextInputType.url, validator: _required),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  overlayColor: primaryRedDark.withOpacity(0.2),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller, {
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  String? _required(String? val) {
    if (val == null || val.trim().isEmpty) return 'Required';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final price = int.tryParse(_priceC.text.trim()) ?? -1;
    if (price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be a positive number')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final payload = TicketLinkPayload(
      vendor: _vendorC.text.trim(),
      vendorLink: _vendorLinkC.text.trim(),
      price: price,
      imgVendor: _imgVendorC.text.trim(),
    );

    final ok = await widget.onSubmit(payload);
    if (mounted) {
      setState(() {
        _submitting = false;
      });
      if (ok) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create link')),
        );
      }
    }
  }
}
