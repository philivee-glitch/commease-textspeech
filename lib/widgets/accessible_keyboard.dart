import 'package:flutter/material.dart';

class AccessibleKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClose;

  const AccessibleKeyboard({
    super.key,
    required this.controller,
    required this.onClose,
  });

  void _addText(String text) {
    final currentText = controller.text;
    final selection = controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length,
      ),
    );
  }

  void _backspace() {
    final currentText = controller.text;
    final selection = controller.selection;
    
    if (selection.start > 0) {
      final newText = currentText.replaceRange(
        selection.start - 1,
        selection.end,
        '',
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar with Done button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onClose,
                    icon: const Icon(Icons.keyboard_hide),
                    label: const Text('Done'),
                  ),
                ],
              ),
            ),
            // Number row
            _buildRow([
              '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
            ]),
            // First QWERTY row
            _buildRow([
              'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
            ]),
            // Second QWERTY row
            _buildRow([
              'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
            ]),
            // Third QWERTY row with backspace
            Row(
              children: [
                Expanded(
                  child: _buildRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M']),
                ),
                _buildKey(
                  context,
                  label: '⌫',
                  onPressed: _backspace,
                  flex: 2,
                ),
              ],
            ),
            // Bottom row with space and punctuation
            Row(
              children: [
                _buildKey(context, label: ',', onPressed: () => _addText(',')),
                _buildKey(context, label: '.', onPressed: () => _addText('.')),
                _buildKey(
                  context,
                  label: 'Space',
                  onPressed: () => _addText(' '),
                  flex: 4,
                ),
                _buildKey(context, label: '!', onPressed: () => _addText('!')),
                _buildKey(context, label: '?', onPressed: () => _addText('?')),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return _buildKey(
          null,
          label: key,
          onPressed: () => _addText(key),
        );
      }).toList(),
    );
  }

  Widget _buildKey(
    BuildContext? context, {
    required String label,
    required VoidCallback onPressed,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}