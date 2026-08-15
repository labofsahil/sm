import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/transfer_item.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/qr_dialog.dart';

enum HistoryFilter { all, sent, received }

class HistoryTab extends StatefulWidget {
  final List<TransferItem> history;
  final VoidCallback? onClearHistory;
  final void Function(int index)? onDeleteItem;

  const HistoryTab({
    super.key,
    required this.history,
    this.onClearHistory,
    this.onDeleteItem,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  HistoryFilter _filter = HistoryFilter.all;

  List<TransferItem> get _filteredHistory {
    switch (_filter) {
      case HistoryFilter.all:
        return widget.history;
      case HistoryFilter.sent:
        return widget.history.where((item) => item.isSend).toList();
      case HistoryFilter.received:
        return widget.history.where((item) => !item.isSend).toList();
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredHistory;

    return Column(
      children: [
        // Filter Chips & Clear Action
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            children: [
              _buildFilterChip('All', HistoryFilter.all, widget.history.length),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Sent',
                HistoryFilter.sent,
                widget.history.where((i) => i.isSend).length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Received',
                HistoryFilter.received,
                widget.history.where((i) => !i.isSend).length,
              ),
              const Spacer(),
              if (widget.history.isNotEmpty && widget.onClearHistory != null)
                IconButton(
                  onPressed: widget.onClearHistory,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                  color: Colors.grey[500],
                  tooltip: 'Clear History',
                ),
            ],
          ),
        ),

        // List View or Empty State
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: Colors.grey[700],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filter == HistoryFilter.all
                            ? 'No transfer history yet'
                            : _filter == HistoryFilter.sent
                                ? 'No sent transfers'
                                : 'No received transfers',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final fileName = item.path.split(Platform.pathSeparator).last;
                    final isComplete =
                        item.status == 'Completed' || item.status == 'Sharing';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.isSend
                                      ? AppTheme.primary.withValues(alpha: 0.1)
                                      : AppTheme.secondary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.isSend
                                      ? Icons.upload_rounded
                                      : Icons.download_rounded,
                                  color: item.isSend
                                      ? AppTheme.primaryLight
                                      : AppTheme.secondaryLight,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName.isEmpty ? 'Directory' : fileName,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.isSend
                                          ? 'Shared via P2P'
                                          : 'Saved to ${item.path}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isComplete
                                          ? AppTheme.emeraldColor
                                              .withValues(alpha: 0.12)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isComplete
                                            ? AppTheme.emeraldAccentColor
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimestamp(item.timestamp),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.borderSubtle),
                          const SizedBox(height: 8),

                          // Bottom item bar with size and quick actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.size > BigInt.zero
                                    ? StorageService.formatBytes(item.size)
                                    : (item.files.isNotEmpty
                                        ? '${item.files.length} files'
                                        : 'P2P Transfer'),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  if (item.ticket.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.qr_code_rounded,
                                        color: AppTheme.secondaryLight,
                                        size: 18,
                                      ),
                                      tooltip: 'View QR Code',
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        QrDialog.show(
                                          context,
                                          ticket: item.ticket,
                                          fileName: fileName,
                                        );
                                      },
                                    ),
                                  if (isComplete) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.folder_open_rounded,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      tooltip: 'Open Folder',
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final opened =
                                            await StorageService.openFolder(
                                          item.path,
                                        );
                                        if (!opened && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Saved to: ${item.path}',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                  if (!item.isSend &&
                                      item.status == 'Completed') ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.share_rounded,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      tooltip: 'Share File',
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        if (item.files.isNotEmpty) {
                                          // ignore: deprecated_member_use
                                          Share.shareXFiles(
                                            item.files
                                                .map((f) => XFile(f))
                                                .toList(),
                                            subject: 'Shared from Sendme',
                                          );
                                        } else {
                                          // ignore: deprecated_member_use
                                          Share.shareXFiles(
                                            [XFile(item.path)],
                                            subject: 'Shared from Sendme',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, HistoryFilter filter, int count) {
    final isSelected = _filter == filter;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : Colors.grey[400],
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryLight : AppTheme.border,
      ),
    );
  }
}
