import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tabs_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/http_utils.dart';
import '../../../core/widgets/code_viewer.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

Color _getStatusColor(BuildContext context, int statusCode) {
  final colors = context.colors;
  if (statusCode >= 200 && statusCode < 300) return colors.success;
  if (statusCode >= 300 && statusCode < 400) return colors.accent;
  if (statusCode >= 400 && statusCode < 500) return colors.warning;
  return colors.error;
}

class ResponsePanel extends ConsumerStatefulWidget {
  final RequestTab tab;
  const ResponsePanel({super.key, required this.tab});

  @override
  ConsumerState<ResponsePanel> createState() => _ResponsePanelState();
}

class _ResponsePanelState extends ConsumerState<ResponsePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.tab.response;
    final isLoading = widget.tab.isLoading;
    final colors = context.colors;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: colors.accent),
            const SizedBox(height: 12),
            Text('Sending request...',
                style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        ),
      );
    }

    if (response == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined, size: 36, color: colors.textDisabled),
            const SizedBox(height: 12),
            Text('Send a request to see the response',
                style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ],
        ),
      );
    }

    final statusColor = _getStatusColor(context, response.statusCode);

    return Column(
      children: [
        // Response meta bar
        Container(
          color: colors.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: statusColor.withAlpha(77),
                  ),
                ),
                child: Text(
                  '${response.statusCode} ${response.statusMessage}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Time
              _MetaChip(
                  icon: Icons.timer_outlined,
                  label: HttpUtils.formatDuration(response.durationMs)),
              const SizedBox(width: 8),
              // Size
              _MetaChip(
                  icon: Icons.data_usage_outlined,
                  label: HttpUtils.formatSize(response.sizeBytes)),
              const Spacer(),
              // Copy button
              Tooltip(
                message: 'Copy response body',
                child: IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 14),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: response.body)),
                  color: colors.textMuted,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
        // Response tab bar
        Container(
          color: colors.bgSurface,
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Body'),
              Tab(text: 'Headers'),
              Tab(text: 'Cookies'),
            ],
          ),
        ),
        const Divider(height: 1),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _ResponseBody(response: response),
              _ResponseHeaders(headers: response.headers),
              _ResponseCookies(cookies: response.cookies),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      ],
    );
  }
}

// ─── Response Body ──────────────────────────────────────────────────────────

class _ResponseBody extends StatefulWidget {
  final dynamic response;
  const _ResponseBody({required this.response});

  @override
  State<_ResponseBody> createState() => _ResponseBodyState();
}

enum _ViewMode { pretty, rendered, raw }

class _ResponseBodyState extends State<_ResponseBody> {
  _ViewMode _mode = _ViewMode.pretty;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentType = widget.response.contentType as String?;
    final isJson = HttpUtils.isJson(contentType);
    final isXml = HttpUtils.isXml(contentType);
    final isHtml = HttpUtils.isHtml(contentType);
    final body = widget.response.body as String;
    final colors = context.colors;

    String language = 'plaintext';
    String formatLabel = 'TEXT';
    String displayBody = body;

    if (isJson) {
      language = 'json';
      formatLabel = 'JSON';
    } else if (isXml) {
      language = 'xml';
      formatLabel = 'XML';
    } else if (isHtml) {
      language = 'html';
      formatLabel = 'HTML';
    }

    if (_mode == _ViewMode.pretty) {
      if (isJson) {
        displayBody = HttpUtils.prettyJson(body);
      } else if (isXml) {
        displayBody = HttpUtils.prettyXml(body);
      } else if (isHtml) {
        displayBody = HttpUtils.prettyHtml(body);
      }
    }

    return Column(
      children: [
        // Toolbar: view mode toggles + format badge
        Container(
          color: colors.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _ToggleBtn(
                label: 'Pretty',
                active: _mode == _ViewMode.pretty,
                onTap: () => setState(() => _mode = _ViewMode.pretty),
              ),
              const SizedBox(width: 4),
              // Only show Rendered toggle for HTML
              if (isHtml) ...[
                _ToggleBtn(
                  label: 'Rendered',
                  active: _mode == _ViewMode.rendered,
                  onTap: () => setState(() => _mode = _ViewMode.rendered),
                ),
                const SizedBox(width: 4),
              ],
              _ToggleBtn(
                label: 'Raw',
                active: _mode == _ViewMode.raw,
                onTap: () => setState(() => _mode = _ViewMode.raw),
              ),
              const Spacer(),
              if (body.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.accentSubtle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(formatLabel,
                      style: AppTypography.mono.copyWith(
                          fontSize: 10,
                          color: colors.accent,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Body content
        Expanded(
          child: body.isEmpty
              ? Center(
                  child: Text('Empty response body',
                      style: TextStyle(fontSize: 12, color: colors.textMuted)))
              : _buildBody(body, displayBody, language, isHtml),
        ),
      ],
    );
  }

  Widget _buildBody(String raw, String display, String language, bool isHtml) {
    // Rendered HTML view
    if (_mode == _ViewMode.rendered && isHtml) {
      return Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: HtmlWidget(raw, textStyle: const TextStyle(fontSize: 13)),
        ),
      );
    }

    // Raw view — plain monospace, no highlighting
    if (_mode == _ViewMode.raw) {
      return Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: SelectableText(
              raw,
              style: AppTypography.mono.copyWith(fontSize: 12),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      );
    }

    // Pretty view — syntax highlighted
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SelectionArea(
          child: CodeViewer(
            code: display,
            language: language,
          ),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.accentSubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? colors.accent : colors.textMuted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Response Headers ────────────────────────────────────────────────────────

class _ResponseHeaders extends StatelessWidget {
  final Map<String, String> headers;
  const _ResponseHeaders({required this.headers});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (headers.isEmpty) {
      return Center(
          child: Text('No response headers',
              style: TextStyle(fontSize: 12, color: colors.textMuted)));
    }
    return Scrollbar(
      child: ListView.builder(
        itemCount: headers.length,
        itemBuilder: (ctx, i) {
          final key = headers.keys.elementAt(i);
          final value = headers[key]!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: colors.border, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(key,
                      style: TextStyle(
                          fontSize: 12,
                          color: colors.accent,
                          fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: SelectableText(value,
                      style:
                          TextStyle(fontSize: 12, color: colors.textPrimary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Response Cookies ────────────────────────────────────────────────────────

class _ResponseCookies extends StatelessWidget {
  final List<Map<String, String>> cookies;
  const _ResponseCookies({required this.cookies});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (cookies.isEmpty) {
      return Center(
          child: Text('No cookies in this response',
              style: TextStyle(fontSize: 12, color: colors.textMuted)));
    }
    return ListView.builder(
      itemCount: cookies.length,
      itemBuilder: (ctx, i) {
        final cookie = cookies[i];
        return ListTile(
          title: Text(cookie['name'] ?? '',
              style: TextStyle(fontSize: 13, color: colors.textPrimary)),
          subtitle: Text(cookie['value'] ?? '',
              style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        );
      },
    );
  }
}
