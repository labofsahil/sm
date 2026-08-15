import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/error_card.dart';

class ReceiveTab extends StatelessWidget {
  final TextEditingController ticketController;
  final TextEditingController destController;
  final bool isReceiving;
  final String receiveStatus;
  final double receiveProgress;
  final String? receiveSpeed;
  final String? elapsedTime;
  final String? receiveError;
  final VoidCallback onPickDestFolder;
  final VoidCallback onShowStorageInfo;
  final VoidCallback onStartDownloading;
  final VoidCallback onCancelDownloading;

  const ReceiveTab({
    super.key,
    required this.ticketController,
    required this.destController,
    required this.isReceiving,
    required this.receiveStatus,
    required this.receiveProgress,
    this.receiveSpeed,
    this.elapsedTime,
    required this.receiveError,
    required this.onPickDestFolder,
    required this.onShowStorageInfo,
    required this.onStartDownloading,
    required this.onCancelDownloading,
  });

  @override
  Widget build(BuildContext context) {
    if (isReceiving) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildActiveReceiveCard(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DOWNLOAD FROM PEER',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryLight,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: ticketController,
            label: 'Enter Share Ticket',
            hint: 'Paste the ticket string here...',
            icon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 18),
          _buildFolderField(),
          const SizedBox(height: 28),
          ActionButton(
            onPressed: onStartDownloading,
            text: 'Download Files',
            icon: Icons.download_rounded,
          ),
          if (receiveError != null) ...[
            const SizedBox(height: 20),
            ErrorCard(message: receiveError!),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveReceiveCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.05),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOWNLOADING ACTIVE',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'P2P Data Transfer',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SpinKitRing(
                color: AppTheme.secondary,
                size: 24,
                lineWidth: 2,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 16),

          // Transfer Status & Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  receiveStatus,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[300],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (receiveSpeed != null || elapsedTime != null)
                Row(
                  children: [
                    if (receiveSpeed != null && receiveSpeed!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          receiveSpeed!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryLight,
                          ),
                        ),
                      ),
                    if (elapsedTime != null && elapsedTime!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          elapsedTime!,
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: receiveProgress,
              minHeight: 8,
              backgroundColor: AppTheme.backgroundLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: onCancelDownloading,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel Download'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppTheme.primaryLight, size: 20),
          border: InputBorder.none,
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[700], fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFolderField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            color: AppTheme.primaryLight,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: destController,
              readOnly: Platform.isAndroid || Platform.isIOS,
              style: GoogleFonts.inter(
                color: (Platform.isAndroid || Platform.isIOS)
                    ? Colors.grey[400]
                    : Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Destination Directory',
                labelStyle: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onPickDestFolder,
            icon: const Icon(
              Icons.folder_copy_rounded,
              color: Colors.grey,
              size: 20,
            ),
            tooltip: 'Browse Folder',
          ),
          IconButton(
            onPressed: onShowStorageInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.grey,
              size: 20,
            ),
            tooltip: 'Storage Info',
          ),
        ],
      ),
    );
  }
}
