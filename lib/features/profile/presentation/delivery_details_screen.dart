import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/delivery_details.dart';
import 'providers/delivery_details_provider.dart';

class DeliveryDetailsScreen extends ConsumerStatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  ConsumerState<DeliveryDetailsScreen> createState() =>
      _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends ConsumerState<DeliveryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final details = ref.read(deliveryDetailsProvider);
    if (details != null) {
      _recipientController.text = details.recipient;
      _phoneController.text = details.phone;
      _addressController.text = details.address;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(deliveryDetailsProvider.notifier)
        .save(
          DeliveryDetails(
            recipient: _recipientController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ nhận hàng')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                Text('Thông tin mặc định', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Thông tin này sẽ được điền sẵn khi đặt hàng. Bạn có thể sửa lại ở từng đơn.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _recipientController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Nhập tên người nhận.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) =>
                      RegExp(r'^0\d{9,10}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Nhập số điện thoại hợp lệ.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ nhận hàng',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 8
                      ? 'Nhập địa chỉ giao hàng đầy đủ.'
                      : null,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Lưu địa chỉ'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Địa chỉ mẫu chỉ lưu trong phiên sử dụng ứng dụng này.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
