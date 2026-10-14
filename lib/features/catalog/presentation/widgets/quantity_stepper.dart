import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A compact quantity control shared by product selection and the cart.
class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.stock,
    required this.onChanged,
  });

  final int quantity;
  final int stock;
  final ValueChanged<int> onChanged;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode.addListener(_normalizeOnBlur);
  }

  void _normalizeOnBlur() {
    if (!_focusNode.hasFocus) _setText(widget.quantity);
  }

  void _setText(int value) {
    final text = '$value';
    if (_controller.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _changeQuantity(int value) {
    if (widget.stock < 1) return;
    final quantity = value.clamp(1, widget.stock);
    _setText(quantity);
    widget.onChanged(quantity);
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) _setText(widget.quantity);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_normalizeOnBlur);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.stock > 0;
    return SizedBox(
      width: 140,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Giảm số lượng',
                onPressed: enabled && widget.quantity > 1
                    ? () => _changeQuantity(widget.quantity - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded, size: 18),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Semantics(
                  label: 'Số lượng sản phẩm',
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '1',
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onChanged: (text) {
                      if (text.isEmpty) return;
                      _changeQuantity(int.tryParse(text) ?? widget.stock);
                    },
                    onSubmitted: (_) {
                      _setText(widget.quantity);
                      _focusNode.unfocus();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 42,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Tăng số lượng',
                onPressed: enabled && widget.quantity < widget.stock
                    ? () => _changeQuantity(widget.quantity + 1)
                    : null,
                icon: const Icon(Icons.add_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
