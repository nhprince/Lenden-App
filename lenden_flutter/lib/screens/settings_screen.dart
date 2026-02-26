import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import '../core/api/api_client.dart';
import '../app/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final shop = ref.watch(shopProvider).currentShop;
    final lang = ref.watch(languageProvider);
    final isEn = lang == 'en';

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          Text(isEn ? 'Profile' : 'প্রোফাইল', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _ProfileCard(user: auth.user, isEn: isEn),
          const SizedBox(height: 32),

          // Business Section
          Text(isEn ? 'Business Settings' : 'ব্যাবসা সেটিংস', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: LucideIcons.building,
            title: isEn ? 'Shop Profile' : 'শপ প্রোফাইল',
            subtitle: shop?.name ?? '',
            onTap: () => _showShopSettings(context, shop),
          ),
          _SettingsTile(
            icon: LucideIcons.fileText,
            title: isEn ? 'Invoice Settings' : 'ইনভয়েস সেটিংস',
            subtitle: isEn ? 'Header, Footer & Terms' : 'হেডার, ফুটার এবং শর্তাবলী',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // Preferences Section
          Text(isEn ? 'Preferences' : 'পছন্দসমূহ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: LucideIcons.languages,
            title: isEn ? 'Language' : 'ভাষা',
            subtitle: isEn ? 'English' : 'বাংলা',
            trailing: Switch(
              value: lang == 'bn',
              onChanged: (_) => ref.read(languageProvider.notifier).toggleLanguage(),
              activeColor: AppTheme.primary600,
            ),
          ),
          _SettingsTile(
            icon: LucideIcons.shieldCheck,
            title: isEn ? 'Security' : 'নিরাপত্তা',
            subtitle: isEn ? 'Change Password' : 'পাসওয়ার্ড পরিবর্তন',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // Tools Section
          Text(isEn ? 'Tools' : 'সরঞ্জাম', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: LucideIcons.database,
            title: isEn ? 'Data Backup' : 'ডাটা ব্যাকআপ',
            subtitle: isEn ? 'Export to JSON' : 'জেসন ফাইলে এক্সপোর্ট করুন',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          
          // Logout
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(LucideIcons.logOut, size: 20, color: Colors.red),
              label: Text(isEn ? 'Logout' : 'লগআউট', style: const TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showShopSettings(BuildContext context, dynamic shop) {
    if (shop == null) return;
    // Show a bottom sheet or dialog to edit shop info
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final bool isEn;
  const _ProfileCard({required this.user, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary600.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary600.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primary600,
            child: Text(
              user?.name[0].toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(user?.email ?? '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary600, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    user?.role.toUpperCase() ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.edit2, size: 20, color: AppTheme.primary600),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primary50, shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primary600, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
      ),
    );
  }
}
