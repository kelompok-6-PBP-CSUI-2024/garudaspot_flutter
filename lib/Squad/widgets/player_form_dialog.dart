import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerFormDialog extends StatefulWidget {
  final Player? player;
  final void Function(Map<String, String>) onSubmit;

  const PlayerFormDialog({
    super.key,
    this.player,
    required this.onSubmit,
  });

  @override
  State<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends State<PlayerFormDialog> {
  late TextEditingController name;
  late TextEditingController photoUrl;
  late TextEditingController birthDate;
  late TextEditingController heightCm;
  late TextEditingController club;
  late TextEditingController caps;
  late TextEditingController goals;
  late TextEditingController assists;

  String pos1 = '';
  String pos2 = '';
  String pos3 = '';

  final positions = const [
    '',
    'GK','LWB','LB','CB','RB','RWB',
    'LM','CM','CDM','CAM','RM',
    'LW','ST','RW'
  ];

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.player?.name ?? '');
    photoUrl = TextEditingController(text: widget.player?.photoUrl ?? '');
    birthDate = TextEditingController(text: widget.player?.birthDate ?? '');
    heightCm = TextEditingController(
      text: widget.player?.heightCm?.toString() ?? '',
    );

    club = TextEditingController(text: widget.player?.club ?? '');
    caps = TextEditingController(text: widget.player?.caps.toString() ?? '0');
    goals = TextEditingController(text: widget.player?.goals.toString() ?? '0');
    assists = TextEditingController(text: widget.player?.assists.toString() ?? '0');

    if (widget.player != null && widget.player!.positions.isNotEmpty) {
      pos1 = widget.player!.positions.length > 0 ? widget.player!.positions[0] : '';
      pos2 = widget.player!.positions.length > 1 ? widget.player!.positions[1] : '';
      pos3 = widget.player!.positions.length > 2 ? widget.player!.positions[2] : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.player == null ? 'Tambah Pemain' : 'Edit Pemain'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _input(name, 'Nama'),
            _input(photoUrl, 'Foto (URL)'),
            _datePicker(),
            _input(heightCm, 'Tinggi (cm)', number: true),
            _dropdown('Position 1', pos1, (v) => setState(() => pos1 = v)),
            _dropdown('Position 2', pos2, (v) => setState(() => pos2 = v)),
            _dropdown('Position 3', pos3, (v) => setState(() => pos3 = v)),
            _input(club, 'Klub saat ini'),
            _input(caps, 'Caps', number: true),
            _input(goals, 'Goals', number: true),
            _input(assists, 'Assists', number: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _submit() {
    final data = <String, String>{};

    if (name.text.trim().isNotEmpty) {
      data['name'] = name.text.trim();
    }

    if (photoUrl.text.trim().isNotEmpty) {
      data['photo_url'] = photoUrl.text.trim();
    }

    if (birthDate.text.isNotEmpty) {
      data['birth_date'] = birthDate.text;
    }

    if (heightCm.text.isNotEmpty) {
      data['height_cm'] = heightCm.text;
    }

    data['position1'] = pos1;
    data['position2'] = pos2;
    data['position3'] = pos3;
    data['club'] = club.text;
    data['caps'] = caps.text.isEmpty ? '0' : caps.text;
    data['goals'] = goals.text.isEmpty ? '0' : goals.text;
    data['assists'] = assists.text.isEmpty ? '0' : assists.text;

    widget.onSubmit(data);
    Navigator.pop(context);
  }

  Widget _input(TextEditingController c, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: birthDate,
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Tanggal lahir'),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            firstDate: DateTime(1970),
            lastDate: DateTime.now(),
            initialDate: DateTime.now(),
          );
          if (d != null) {
            birthDate.text =
                "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }

  Widget _dropdown(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(labelText: label),
        items: positions
            .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.isEmpty ? '—' : p),
                ))
            .toList(),
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }
}
