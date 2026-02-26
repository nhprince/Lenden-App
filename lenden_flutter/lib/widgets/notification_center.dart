import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import '../app/theme.dart';

class NotificationCenter extends ConsumerStatefulWidget {
  const NotificationCenter({super.key});

  @override
  ConsumerState<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends ConsumerState<NotificationCenter> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final isEn = ref.watch(languageProvider) == 'en';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEn ? 'Notifications' : 'নোটিফিকেশন',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (state.unreadCount > 0)
                    TextButton(
                      onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
                      child: Text(isEn ? 'Mark all as read' : 'সব পঠিত লিখুন'),
                    ),
                ],
              ),
            ),
            const Divider(),
            // List
            Expanded(
              child: state.isLoading && state.notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.bellOff, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text(
                                isEn ? 'No notifications yet' : 'কোনো নোটিফিকেশন নেই',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final notification = state.notifications[index];
                            return _NotificationTile(notification: notification);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final dynamic notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(languageProvider) == 'en';
    final color = _getTypeColor(notification.type);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.red),
      ),
      onDismissed: (_) {
        ref.read(notificationProvider.notifier).deleteNotification(notification.id as int);
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(notification.id as int);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.transparent : color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getTypeIcon(notification.type), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(notification.createdAt.toString()),
                      style: TextStyle(color: AppTheme.textLight, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'OVERDUE_PAYMENT':
        return LucideIcons.alertTriangle;
      case 'LOW_STOCK':
        return LucideIcons.package2;
      case 'DAILY_SUMMARY':
        return LucideIcons.fileText;
      case 'MONTHLY_SUMMARY':
        return LucideIcons.barChart;
      case 'NEW_STAFF':
        return LucideIcons.userPlus;
      case 'STAFF_ROLE_CHANGE':
        return LucideIcons.shieldCheck;
      case 'BACKUP_CREATED':
        return LucideIcons.database;
      case 'RESTORE_SUCCESS':
        return LucideIcons.refreshCw;
      case 'RENTAL_OVERDUE':
        return LucideIcons.truck;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getTypeColor(String type) {
    if (type.contains('OVERDUE') || type.contains('LOW')) return Colors.red;
    if (type.contains('SUMMARY')) return Colors.blue;
    if (type.contains('STAFF')) return Colors.green;
    return Colors.orange;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
