import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/error_card.dart';
import '../../widgets/common/pulse_dot.dart';
import '../../widgets/qr_dialog.dart';

class SendTab extends StatelessWidget {
  final String? sendPath;
  final FolderStats? folderStats;
  final bool isSending;
  final bool isImporting;
  final String? sendTicket;
  final String sendStatus;
  final double sendProgress;
  final String? sendError;
  final VoidCallback onPickFile;
  final VoidCallback onPickFolder;
  final VoidCallback onClearSelection;
  final VoidCallback onStartSharing;
  final VoidCallback onStopSharing;
  final void Function(String ticket) onCopyTicket;
  final void Function(String ticket) onShareTicket;

  const SendTab({
    super.key,
    required this.sendPath,
    required this.folderStats,
    required this.isSending,
    required this.isImporting,
    required this.sendTicket,
    required this.sendStatus,
    required this.sendProgress,
    required this.sendError,
    required this.onPickFile,
    required this.onPickFolder,
    required this.onClearSelection,
    required this.onStartSharing,
    required this.onStopSharing,
    required this.onCopyTicket,
    required this.onShareTicket,
  });

  @override
  Widget build(BuildContext context) {
    if (isSending) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildActiveSendCard(context),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSendDropZone(),
          const SizedBox(height: 24),
          if (sendPath != null) ...[
            _buildFileDetailCard(),
            const SizedBox(height: 28),
            ActionButton(
              onPressed: onStartSharing,
              text: 'Generate Share Link',
              icon: Icons.offline_bolt_rounded,
            ),
          ],
          if (sendError != null) ...[
            const SizedBox(height: 16),
            ErrorCard(message: sendError!),
          ],
        ],
      ),
    );
  }

  Widget _buildSendDropZone() {
    return GestureDetector(
      onTap: onPickFile,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sendPath != null ? AppTheme.primary : AppTheme.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: AppTheme.primaryLight,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select what you want to share',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.insert_drive_file_rounded, size: 16),
                  label: const Text('Pick File'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onPickFolder,
                  icon: const Icon(Icons.folder_open_rounded, size: 16),
                  label: const Text('Pick Folder'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileDetailCard() {
    final name = sendPath!.split(Platform.pathSeparator).last.isEmpty
        ? sendPath!
        : sendPath!.split(Platform.pathSeparator).last;
    final isFolder = Directory(sendPath!).existsSync() || folderStats != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFolder
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : AppTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
              color: isFolder ? AppTheme.primaryLight : AppTheme.secondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sendPath!,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (folderStats != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${folderStats!.fileCount} ${folderStats!.fileCount == 1 ? "file" : "files"} • ${StorageService.formatBytes(folderStats!.totalBytes)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClearSelection,
            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSendCard(BuildContext context) {
    final fileName = sendPath?.split(Platform.pathSeparator).last ?? 'File';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHARING LIVE',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isImporting)
                const SpinKitRing(
                  color: AppTheme.primary,
                  size: 24,
                  lineWidth: 2,
                )
              else
                const PulseDot(color: AppTheme.emeraldAccentColor),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 16),
          Text(
            sendStatus,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: sendProgress,
              minHeight: 8,
              backgroundColor: AppTheme.backgroundLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          if (sendTicket != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SHARE TICKET',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => QrDialog.show(
                    context,
                    ticket: sendTicket!,
                    fileName: fileName,
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text('Show QR Code'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryLight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sendTicket!,
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: AppTheme.secondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onCopyTicket(sendTicket!),
                    icon: const Icon(
                      Icons.content_copy_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    tooltip: 'Copy Ticket',
                  ),
                  IconButton(
                    onPressed: () => onShareTicket(sendTicket!),
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    tooltip: 'Share',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipient can download using this ticket or by scanning the QR code.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: onStopSharing,
            icon: const Icon(Icons.stop_rounded, size: 18),
            label: const Text('Stop Sharing'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: BorderSide(
                color: AppTheme.errorColor.withValues(alpha: 0.4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
