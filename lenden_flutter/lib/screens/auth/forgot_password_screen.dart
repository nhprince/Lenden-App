import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleSubmit() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
    setState(() { _isLoading = false; _emailSent = success; });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('If an account exists, instructions have been sent.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.go('/'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Forgot Password', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Enter your email to receive reset instructions.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(LucideIcons.mail, size: 20))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_emailSent ? 'Resend Email' : 'Send Reset Link'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
