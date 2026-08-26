import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

enum LogLevelFilter { all, error, warn, info, debug }

class LogsTab extends StatefulWidget {
  final List<String> logs;
  final ScrollController scrollController;
  final VoidCallback onCopyLogs;
  final VoidCallback onClearLogs;

  const LogsTab({
    super.key,
    required this.logs,
    required this.scrollController,
    required this.onCopyLogs,
    required this.onClearLogs,
  });

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  LogLevelFilter _selectedLevel = LogLevelFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredLogs {
    return widget.logs.where((line) {
      final lower = line.toLowerCase();
      // Level filter
      if (_selectedLevel == LogLevelFilter.error) {
        if (!lower.contains('[error]') && !lower.contains('error')) return false;
      } else if (_selectedLevel == LogLevelFilter.warn) {
        if (!lower.contains('[warn]') && !lower.contains('warn')) return false;
      } else if (_selectedLevel == LogLevelFilter.info) {
        if (!lower.contains('[info]') && !lower.contains('info')) return false;
      } else if (_selectedLevel == LogLevelFilter.debug) {
        if (!lower.contains('[debug]') && !lower.contains('debug')) return false;
      }

      // Search text filter
      if (_searchQuery.isNotEmpty && !lower.contains(_searchQuery)) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getLineColor(String line) {
    final lower = line.toLowerCase();
    if (lower.contains('[error]') || lower.contains('error')) {
      return AppTheme.errorAccentColor;
    } else if (lower.contains('[warn]') || lower.contains('warn')) {
      return AppTheme.warningAccentColor;
    } else if (lower.contains('[info]')) {
      return AppTheme.emeraldAccentColor;
    } else if (lower.contains('[debug]')) {
      return AppTheme.secondaryLight;
    }
    return Colors.grey[400]!;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;

    return Column(
      children: [
        // Controls Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            children: [
              // Top action bar
              Row(
                children: [
                  const Icon(
                    Icons.terminal_rounded,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rust Debug Logs',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filtered.length}/${widget.logs.length} lines',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _autoScroll = !_autoScroll;
                      });
                    },
                    icon: Icon(
                      _autoScroll
                          ? Icons.vertical_align_bottom_rounded
                          : Icons.pause_circle_outline_rounded,
                      size: 18,
                      color: _autoScroll ? AppTheme.emeraldAccentColor : Colors.grey,
                    ),
                    tooltip: _autoScroll ? 'Auto-scroll Enabled' : 'Auto-scroll Paused',
                  ),
                  TextButton.icon(
                    onPressed: widget.logs.isEmpty ? null : widget.onCopyLogs,
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('Copy'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        widget.logs.isEmpty ? null : widget.onClearLogs,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 15),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Search & Filter row
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Search logs...',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Log level filter chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildLevelChip('ALL', LogLevelFilter.all),
                    const SizedBox(width: 6),
                    _buildLevelChip(
                      'ERROR',
                      LogLevelFilter.error,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 6),
                    _buildLevelChip(
                      'WARN',
                      LogLevelFilter.warn,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 6),
                    _buildLevelChip(
                      'INFO',
                      LogLevelFilter.info,
                      color: AppTheme.emeraldColor,
                    ),
                    const SizedBox(width: 6),
                    _buildLevelChip(
                      'DEBUG',
                      LogLevelFilter.debug,
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Terminal Log Container
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty_rounded,
                          color: Colors.grey[700],
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.logs.isEmpty
                              ? 'No logs yet.\nStart a send or receive operation to see logs.'
                              : 'No matching log lines for this filter.',
                          style: GoogleFonts.robotoMono(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final line = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SelectableText(
                          line,
                          style: GoogleFonts.robotoMono(
                            color: _getLineColor(line),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChip(
    String label,
    LogLevelFilter filter, {
    Color? color,
  }) {
    final isSelected = _selectedLevel == filter;
    final activeColor = color ?? AppTheme.primary;

    return InkWell(
      onTap: () => setState(() => _selectedLevel = filter),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
