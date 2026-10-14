import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/demo_account.dart';
import 'providers/demo_account_provider.dart';

class RegisterAccountScreen extends ConsumerStatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  ConsumerState<RegisterAccountScreen> createState() =>
      _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends ConsumerState<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    final account = ref.read(demoAccountProvider);
    _isEditing = account != null;
    _nameController = TextEditingController(text: account?.name);
    _phoneController = TextEditingController(text: account?.phone);
    _emailController = TextEditingController(text: account?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(demoAccountProvider.notifier)
        .save(
          DemoAccount(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa tài khoản' : 'Đăng ký tài khoản'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _isEditing ? 'Thông tin cá nhân' : 'Tạo tài khoản trải nghiệm',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Thông tin chỉ lưu trên ứng dụng trong phiên này.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Tên tài khoản'),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'Nhập tên từ 2 ký tự'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              validator: (value) =>
                  RegExp(r'^0[0-9]{9}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Nhập số điện thoại 10 chữ số bắt đầu bằng 0',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Email (không bắt buộc)',
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return null;
                return email.contains('@') &&
                        email.split('@').last.contains('.')
                    ? null
                    : 'Email chưa đúng định dạng';
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(
                _isEditing ? 'Lưu thay đổi' : 'Đăng ký tài khoản mẫu',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
