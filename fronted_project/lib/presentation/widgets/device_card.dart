import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../../models/device.dart';
import '../../services/device_service.dart';
import '../../services/virtual_device_service.dart';
import '../../theme/figma_colors.dart';
import '../../features/agent/fallback_intent_service.dart';
import '../../application/application.dart';
import '../../application/providers.dart';
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed

class DeviceCard extends ConsumerWidget {
  final SmartDevice device;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = device.isOn;
    final name = device.name;
    final icon = device.icon;
    final room = device.room;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isOn ? 1 : 0,
      color: isOn
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMoreTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: isOn
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOn)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, right: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (onMoreTap != null)
                        GestureDetector(
                          onTap: onMoreTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? colorScheme.onPrimaryContainer.withValues(
                                      alpha: 0.1,
                                    )
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.1,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: isOn
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOn
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (room != null) ...[
                        Text(
                          room,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          isOn
                              ? (device is HasTemperature
                                    ? '已开启 ${(device as HasTemperature).temperature}°C'
                                    : '已开启')
                              : '已关闭',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

