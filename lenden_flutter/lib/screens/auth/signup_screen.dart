import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/providers.dart';
import '../../app/theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _shopNameController.text.isNotEmpty ? _shopNameController.text.trim() : null,
        );
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please verify your email.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                Text('Create Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 32),

                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(LucideIcons.user, size: 20)), textInputAction: TextInputAction.next),
                const SizedBox(height: 16),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(LucideIcons.mail, size: 20)), textInputAction: TextInputAction.next),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(LucideIcons.lock, size: 20), suffixIcon: IconButton(icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), textInputAction: TextInputAction.next),
                const SizedBox(height: 16),
                TextField(controller: _shopNameController, decoration: const InputDecoration(labelText: 'Shop Name (Optional)', prefixIcon: Icon(LucideIcons.store, size: 20)), textInputAction: TextInputAction.done),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Already have an account? ", style: TextStyle(color: AppTheme.textSecondary)),
                  TextButton(onPressed: () => context.go('/'), child: const Text('Sign In')),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
