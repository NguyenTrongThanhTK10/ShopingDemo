import 'package:flutter/material.dart';

import 'voice_search_sheet.dart';

class VoiceSearchButton extends StatefulWidget {
  const VoiceSearchButton({
    super.key,
    required this.onSearch,
    this.compact = false,
  });

  final ValueChanged<String> onSearch;
  final bool compact;

  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  bool _open = false;

  Future<void> _listen() async {
    if (_open) return;
    FocusScope.of(context).unfocus();
    setState(() => _open = true);
    final query = await showVoiceSearchSheet(context);
    if (!mounted) return;
    setState(() => _open = false);
    if (query != null && query.trim().isNotEmpty) widget.onSearch(query.trim());
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Tìm kiếm bằng giọng nói',
    onPressed: _open ? null : _listen,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    padding: widget.compact ? EdgeInsets.zero : const EdgeInsets.all(8),
    constraints: widget.compact
        ? const BoxConstraints.tightFor(width: 44, height: 44)
        : null,
    icon: const Icon(Icons.mic_none_rounded, size: 22),
  );
}
