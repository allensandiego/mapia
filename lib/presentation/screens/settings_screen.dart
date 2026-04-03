import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/theme/mapia_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _proxyHostCtrl;
  late TextEditingController _proxyPortCtrl;
  late TextEditingController _timeoutCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _proxyHostCtrl = TextEditingController(text: s.proxyHost);
    _proxyPortCtrl = TextEditingController(text: s.proxyPort.toString());
    _timeoutCtrl = TextEditingController(text: (s.requestTimeoutMs ~/ 1000).toString());
  }

  @override
  void dispose() {
    _proxyHostCtrl.dispose();
    _proxyPortCtrl.dispose();
    _timeoutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Dialog(
      backgroundColor: context.colors.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20, color: context.colors.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                    color: context.colors.textMuted,
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Settings content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Appearance ───────────────────────────────────────
                  const _SectionHeader('Appearance'),
                  const SizedBox(height: 12),
                  _SettingRow(
                    label: 'Theme',
                    description: 'Choose your preferred colour scheme.',
                    child: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: context.colors.bgElevated,
                      style: TextStyle(color: context.colors.textPrimary),
                      items: [
                        DropdownMenuItem(value: ThemeMode.system, child: Text('System', style: TextStyle(color: context.colors.textPrimary))),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark', style: TextStyle(color: context.colors.textPrimary))),
                        DropdownMenuItem(value: ThemeMode.light, child: Text('Light', style: TextStyle(color: context.colors.textPrimary))),
                      ],
                      onChanged: (v) => v != null ? notifier.setThemeMode(v) : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Network ──────────────────────────────────────────
                  const _SectionHeader('Network'),
                  const SizedBox(height: 12),
                  _SettingRow(
                    label: 'SSL Verification',
                    description: 'Verify SSL certificates on HTTPS requests.',
                    child: Switch(
                      value: settings.sslVerification,
                      onChanged: (v) => notifier.setSslVerification(v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingRow(
                    label: 'Request Timeout',
                    description: 'Timeout in seconds for all requests.',
                    child: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _timeoutCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: const OutlineInputBorder(),
                          suffixText: 's',
                          suffixStyle: TextStyle(color: context.colors.textMuted),
                        ),
                        onSubmitted: (v) {
                          final secs = int.tryParse(v) ?? 30;
                          notifier.setRequestTimeout(secs.clamp(1, 300) * 1000);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Proxy ────────────────────────────────────────────
                  const _SectionHeader('Proxy'),
                  const SizedBox(height: 12),
                  _SettingRow(
                    label: 'Proxy Host',
                    description: 'HTTP proxy hostname (leave blank to disable).',
                    child: SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _proxyHostCtrl,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: const OutlineInputBorder(),
                          hintText: 'e.g. 127.0.0.1',
                          hintStyle: TextStyle(color: context.colors.textDisabled),
                        ),
                        onSubmitted: (_) => _saveProxy(notifier),
                        onEditingComplete: () => _saveProxy(notifier),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingRow(
                    label: 'Proxy Port',
                    description: 'Port number for the HTTP proxy.',
                    child: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _proxyPortCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _saveProxy(notifier),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProxy(SettingsNotifier notifier) {
    final host = _proxyHostCtrl.text.trim();
    final port = int.tryParse(_proxyPortCtrl.text.trim()) ?? 8080;
    notifier.setProxy(host, port);
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: context.colors.textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  )),
              const SizedBox(height: 2),
              Text(description,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textMuted,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 16),
        child,
      ],
    );
  }
}
