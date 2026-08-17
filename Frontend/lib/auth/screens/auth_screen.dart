import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../auth_session_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loginMode = true;
  bool _verificationMode = false;
  bool _obscurePassword = true;
  bool _submitting = false;
  UserRole _role = UserRole.customer;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthSessionProvider session) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور.');
      return;
    }

    setState(() => _submitting = true);
    final success = await session.login(email, password);
    if (mounted) setState(() => _submitting = false);
    if (!success && mounted && session.errorMessage != null) {
      _showMessage(session.errorMessage!);
    }
  }

  Future<void> _register(AuthSessionProvider session) async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showMessage('يرجى استكمال جميع البيانات المطلوبة.');
      return;
    }

    setState(() => _submitting = true);
    final success = await session.register(
      fullName: fullName,
      email: email,
      phoneNumber: phone,
      password: password,
      role: _role,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      setState(() => _verificationMode = true);
    } else if (session.errorMessage != null) {
      _showMessage(session.errorMessage!);
    }
  }

  Future<void> _verifyEmail(AuthSessionProvider session) async {
    final email = _emailController.text.trim();
    final code = _verificationCodeController.text.trim();
    if (email.isEmpty || code.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني ورمز التحقق.');
      return;
    }

    setState(() => _submitting = true);
    final success = await session.verifyEmail(email: email, code: code);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      setState(() {
        _verificationMode = false;
        _loginMode = true;
      });
    } else if (session.errorMessage != null) {
      _showMessage(session.errorMessage!);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    final message = session.infoMessage ?? session.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.home_repair_service_rounded,
                    size: 54,
                    color: _role == UserRole.customer
                        ? AppColors.primary
                        : AppColors.technicianPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _verificationMode
                        ? 'تأكيد البريد الإلكتروني'
                        : _loginMode
                            ? 'تسجيل الدخول إلى حسابك'
                            : 'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (message != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: session.errorMessage != null
                            ? AppColors.errorLight
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(message),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!_verificationMode) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('عميل'),
                            selected: _role == UserRole.customer,
                            onSelected: (_) => setState(() => _role = UserRole.customer),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('فني'),
                            selected: _role == UserRole.technician,
                            onSelected: (_) => setState(() => _role = UserRole.technician),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _loginMode = true),
                            child: const Text('تسجيل الدخول'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _loginMode = false),
                            child: const Text('حساب جديد'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_verificationMode)
                    _buildVerificationForm(session)
                  else if (_loginMode)
                    _buildLoginForm(session)
                  else
                    _buildRegisterForm(session),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthSessionProvider session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitting || session.isRefreshing ? null : () => _login(session),
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تسجيل الدخول'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _verificationMode = true),
          child: const Text('لدي رمز تأكيد البريد الإلكتروني'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Google وSMS/OTP غير متاحين في عقد الـAPI الحالي، لذلك لا يتم عرضهما كتسجيل دخول وهمي.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthSessionProvider session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(labelText: 'الاسم بالكامل'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'رقم الهاتف'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitting ? null : () => _register(session),
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إنشاء الحساب'),
        ),
      ],
    );
  }

  Widget _buildVerificationForm(AuthSessionProvider session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _verificationCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'رمز التحقق'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitting ? null : () => _verifyEmail(session),
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد البريد الإلكتروني'),
        ),
        TextButton(
          onPressed: () => setState(() => _verificationMode = false),
          child: const Text('العودة لتسجيل الدخول'),
        ),
      ],
    );
  }
}
