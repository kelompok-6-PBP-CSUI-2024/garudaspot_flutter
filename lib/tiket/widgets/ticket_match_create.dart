import 'package:flutter/material.dart';
import 'package:garudaspot_flutter/tiket/services/ticket_service.dart';
import 'package:garudaspot_flutter/tiket/models/ticket_match.dart';

class TicketMatchForm extends StatefulWidget {
  const TicketMatchForm({
    super.key,
    this.initial,
    required this.onSubmit,
  });

  final TicketMatch? initial;
  final Future<bool> Function(TicketMatchPayload payload) onSubmit;

  @override
  State<TicketMatchForm> createState() => _TicketMatchFormState();
}

class _TicketMatchFormState extends State<TicketMatchForm> {
  final _formKey = GlobalKey<FormState>();
  final _team1C = TextEditingController();
  final _team2C = TextEditingController();
  final _imgTeam1C = TextEditingController();
  final _imgTeam2C = TextEditingController();
  final _imgCupC = TextEditingController();
  final _placeC = TextEditingController();
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _team1C.text = initial.team1;
      _team2C.text = initial.team2;
      _imgTeam1C.text = initial.imgTeam1;
      _imgTeam2C.text = initial.imgTeam2;
      _imgCupC.text = initial.imgCup ?? '';
      _placeC.text = initial.place ?? '';
      _date = initial.date;
    }
  }

  @override
  void dispose() {
    _team1C.dispose();
    _team2C.dispose();
    _imgTeam1C.dispose();
    _imgTeam2C.dispose();
    _imgCupC.dispose();
    _placeC.dispose();
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
                Text(
                  widget.initial == null ? 'Create Match' : 'Edit Match',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _submitting ? null : () => Navigator.pop(context, false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(_team1C, label: 'Team 1', validator: _required),
            _buildTextField(_team2C, label: 'Team 2', validator: _required),
            _buildTextField(_imgTeam1C, label: 'Image URL Team 1', keyboardType: TextInputType.url, validator: _required),
            _buildTextField(_imgTeam2C, label: 'Image URL Team 2', keyboardType: TextInputType.url, validator: _required),
            _buildTextField(_imgCupC, label: 'Image URL Cup (optional)', keyboardType: TextInputType.url),
            _buildTextField(_placeC, label: 'Place (optional)'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _submitting ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_formatDate(_date)),
                ),
              ],
            ),
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
                    : Text(widget.initial == null ? 'Create' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
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
    if (val == null || val.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String _formatDate(DateTime d) => d.toIso8601String().split('T').first;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
    });

    final payload = TicketMatchPayload(
      team1: _team1C.text.trim(),
      team2: _team2C.text.trim(),
      imgTeam1: _imgTeam1C.text.trim(),
      imgTeam2: _imgTeam2C.text.trim(),
      imgCup: _imgCupC.text.trim().isEmpty ? null : _imgCupC.text.trim(),
      place: _placeC.text.trim().isEmpty ? null : _placeC.text.trim(),
      dateIso: _formatDate(_date),
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
          const SnackBar(content: Text('Failed to save match')),
        );
      }
    }
  }
}
