import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/providers.dart';
import 'notification_center.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(notificationProvider.select((s) => s.unreadCount));

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.bell),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const NotificationCenter(),
            );
          },
        ),
        if (unreadCount > 0)
          PositionImage(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Fixed typo in Positioned
class PositionImage extends StatelessWidget {
  final double? top;
  final double? right;
  final Widget child;
  const PositionImage({super.key, this.top, this.right, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, right: right, child: child);
  }
}
