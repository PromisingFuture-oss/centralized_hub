import 'package:flutter/material.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';

/// Base container for all dashboard cards with consistent header, icons, and card options.
class BaseDashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;
  final VoidCallback? onTap;
  final Widget child;

  const BaseDashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.size = CardSize.medium,
    this.onRemove,
    this.onResize,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isSmall = size == CardSize.small;
    final accentColor = iconColor ?? colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: accentColor.withValues(alpha: 0.08),
          highlightColor: accentColor.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 7 : 9),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.28),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: isSmall ? 18 : 20,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: (isSmall
                                          ? textTheme.labelLarge
                                          : textTheme.titleSmall)
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (onTap != null && !isSmall) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ],
                          ),
                          if (subtitle != null && !isSmall)
                            Text(
                              subtitle!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (onRemove != null || onResize != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: isSmall ? 18 : 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'remove') {
                            onRemove?.call();
                          } else if (value.startsWith('size_')) {
                            final sizeName = value.replaceFirst('size_', '');
                            final newSize = CardSize.values.firstWhere(
                              (s) => s.name == sizeName,
                              orElse: () => CardSize.medium,
                            );
                            onResize?.call(newSize);
                          }
                        },
                        itemBuilder: (context) => [
                          if (onResize != null) ...[
                            CheckedPopupMenuItem(
                              value: 'size_small',
                              checked: size == CardSize.small,
                              child: const Text('Small (Half width)'),
                            ),
                            CheckedPopupMenuItem(
                              value: 'size_medium',
                              checked: size == CardSize.medium,
                              child: const Text('Medium (Full width)'),
                            ),
                            CheckedPopupMenuItem(
                              value: 'size_large',
                              checked: size == CardSize.large,
                              child: const Text('Large (Expanded)'),
                            ),
                            const PopupMenuDivider(),
                          ],
                          if (onRemove != null)
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Remove card',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
