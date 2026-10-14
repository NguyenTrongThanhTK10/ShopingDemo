class DemoAccount {
  const DemoAccount({required this.name, required this.phone, this.email = ''});

  final String name;
  final String phone;
  final String email;
}
