import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/environment_provider.dart';
import '../../screens/environment_screen.dart';
import '../../../core/theme/mapia_colors.dart';

class EnvironmentSelector extends ConsumerWidget {
  final bool isCompact;
  const EnvironmentSelector({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isCompact) {
      return InkWell(
        onTap: () => _openEnvManager(context),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.tune_outlined, size: 20, color: context.colors.textSecondary),
        ),
      );
    }

    final envsAsync = ref.watch(environmentsProvider);
    final activeId = ref.watch(activeEnvironmentProvider);

    return Container(
      color: context.colors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.tune_outlined, size: 13, color: context.colors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: envsAsync.when(
              loading: () => Text('Loading...',
                  style:
                      TextStyle(fontSize: 12, color: context.colors.textMuted)),
              error: (_, __) => Text('Error',
                  style: TextStyle(fontSize: 12, color: context.colors.error)),
              data: (envs) {
                final items = [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No Environment',
                        style: TextStyle(
                            fontSize: 12, color: context.colors.textMuted)),
                  ),
                  ...envs.map((e) => DropdownMenuItem<String?>(
                        value: e.id,
                        child: Text(e.name,
                            style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textPrimary)),
                      )),
                  DropdownMenuItem<String?>(
                    value: '__manage__',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 12, color: context.colors.accent),
                        const SizedBox(width: 8),
                        Text('Manage Environments...',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.colors.accent)),
                      ],
                    ),
                  ),
                ];
                return DropdownButton<String?>(
                  value: activeId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: context.colors.bgElevated,
                  iconSize: 14,
                  iconEnabledColor: context.colors.textMuted,
                  items: items,
                  onChanged: (v) {
                    if (v == '__manage__') {
                      _openEnvManager(context);
                    } else {
                      ref.read(activeEnvironmentProvider.notifier).state = v;
                    }
                  },
                );
              },
            ),
          ),
          InkWell(
            onTap: () => _openEnvManager(context),
            borderRadius: BorderRadius.circular(3),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.settings_outlined,
                  size: 13, color: context.colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _openEnvManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const EnvironmentScreen(),
    );
  }
}
