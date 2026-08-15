import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transfer_item.dart';
import '../rust/api/sendme.dart';
import '../rust/api/simple.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/pulse_dot.dart';
import '../widgets/folder_picker_modal.dart';
import 'tabs/history_tab.dart';
import 'tabs/logs_tab.dart';
import 'tabs/receive_tab.dart';
import 'tabs/send_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Send state
  String? _sendPath;
  FolderStats? _folderStats;
  bool _isSending = false;
  bool _isImporting = false;
  String? _sendTicket;
  String _sendStatus = '';
  double _sendProgress = 0.0;
  String? _sendError;
  StreamSubscription<SendProgress>? _sendSub;

  // Receive state
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  bool _isReceiving = false;
  String _receiveStatus = '';
  double _receiveProgress = 0.0;
  String? _receiveError;
  StreamSubscription<ReceiveProgress>? _receiveSub;

  // Speed and Elapsed Time tracking
  DateTime? _receiveStartTime;
  DateTime? _lastSpeedCalcTime;
  BigInt _lastDownloadedBytes = BigInt.zero;
  String? _receiveSpeed;
  String? _elapsedTime;
  Timer? _metricsTimer;

  // History state
  final List<TransferItem> _history = [];

  // Debug log state
  final List<String> _debugLogs = [];
  final ScrollController _logsScrollController = ScrollController();
  Timer? _logPollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeDefaultPaths();

    // Poll Rust log buffer every second
    _logPollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final newLogs = await getDebugLogs();
      if (newLogs.isNotEmpty && mounted) {
        setState(() {
          _debugLogs.addAll(newLogs);
          if (_debugLogs.length > 1000) {
            _debugLogs.removeRange(0, _debugLogs.length - 1000);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logsScrollController.hasClients) {
            _logsScrollController.jumpTo(
              _logsScrollController.position.maxScrollExtent,
            );
          }
        });
      }
    });
  }

  Future<void> _initializeDefaultPaths() async {
    try {
      String sendmePath;
      if (Platform.isAndroid) {
        final pubDownload = Directory('/storage/emulated/0/Download');
        if (await pubDownload.exists()) {
          sendmePath = '/storage/emulated/0/Download/Sendme';
        } else {
          final extDir = await getExternalStorageDirectory();
          sendmePath =
              '${extDir?.path ?? (await getApplicationDocumentsDirectory()).path}/Sendme';
        }
      } else if (Platform.isIOS) {
        sendmePath =
            '${(await getApplicationDocumentsDirectory()).path}/Sendme';
      } else {
        final downloads = await getDownloadsDirectory();
        sendmePath =
            '${(downloads ?? await getApplicationDocumentsDirectory()).path}/Sendme';
      }

      final dir = Directory(sendmePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (mounted) {
        setState(() {
          _destController.text = sendmePath;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _logPollTimer?.cancel();
    _metricsTimer?.cancel();
    _logsScrollController.dispose();
    _tabController.dispose();
    _sendSub?.cancel();
    _receiveSub?.cancel();
    _ticketController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _pickSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _sendPath = result.files.single.path;
          _folderStats = null;
          _sendError = null;
        });
      }
    } catch (e) {
      setState(() {
        _sendError = 'Error picking file: $e';
      });
    }
  }

  Future<void> _pickSendFolder() async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await StorageService.checkStoragePermission();
        if (!hasPermission && mounted) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surface,
              title: Text(
                'Storage Permission Required',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Sendme requires All Files Access to share entire directories and their contents over P2P.\n\nPlease enable permission in Settings.',
                style: GoogleFonts.inter(
                  color: Colors.grey[300],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                    StorageService.requestStoragePermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          if (proceed != true) return;
        }
      }

      if (!mounted) return;
      final selectedPath =
          await FolderPickerModal.show(context, initialPath: _sendPath);
      if (selectedPath != null && selectedPath.isNotEmpty) {
        if (selectedPath == '/' || selectedPath == '\\') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cannot share root directory. Please select a specific folder.',
                ),
              ),
            );
          }
          return;
        }

        final stats = await StorageService.inspectFolder(selectedPath);
        setState(() {
          _sendPath = selectedPath;
          _folderStats = stats;
          _sendError = null;
        });
      }
    } catch (e) {
      setState(() {
        _sendError = 'Error picking folder: $e';
      });
    }
  }

  Future<void> _pickDestFolder() async {
    try {
      final selectedPath =
          await FolderPickerModal.show(context, initialPath: _destController.text);
      if (selectedPath != null && selectedPath.isNotEmpty) {
        if (selectedPath == '/' || selectedPath == '\\') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cannot use root directory. Please select a specific folder.',
                ),
              ),
            );
          }
          return;
        }
        setState(() {
          _destController.text = selectedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking folder: $e')),
        );
      }
    }
  }

  void _showStorageInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Storage Location Info',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Files and folders are saved directly to your device\'s public Downloads folder (Downloads/Sendme).\n\n'
          'Current Location:\n${_destController.text}\n\n'
          'You can open this folder using your File Manager or tap "Open Folder" in the History tab to browse complete nested folder structures.',
          style: GoogleFonts.inter(
            color: Colors.grey[300],
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startSharing() async {
    if (_sendPath == null || _sendPath == '/' || _sendPath == '\\') {
      setState(() {
        _sendError =
            'Cannot share root directory. Please select a valid file or folder.';
      });
      return;
    }

    setState(() {
      _isSending = true;
      _isImporting = true;
      _sendTicket = null;
      _sendStatus = 'Initializing...';
      _sendProgress = 0.0;
      _sendError = null;
    });

    try {
      final temp = await getTemporaryDirectory();
      _sendSub =
          startSend(path: _sendPath!, tempDir: temp.path).listen((progress) {
        progress.when(
          importing: (fileName, bytesDone, bytesTotal) {
            setState(() {
              _isImporting = true;
              _sendStatus = 'Importing: $fileName';
              _sendProgress = bytesTotal > BigInt.zero
                  ? bytesDone.toDouble() / bytesTotal.toDouble()
                  : 0.0;
            });
          },
          importDone: (totalSize) {
            setState(() {
              _isImporting = false;
              _sendStatus = 'Import complete. Sharing...';
              _sendProgress = 1.0;
            });
          },
          startingEndpoint: () {
            setState(() {
              _sendStatus = 'Starting Iroh node...';
              _sendProgress = 0.0;
            });
          },
          sharing: (ticket) {
            setState(() {
              _isSending = true;
              _sendTicket = ticket;
              _sendStatus = 'Active & Available';
              _sendProgress = 1.0;

              final existingIndex =
                  _history.indexWhere((item) => item.ticket == ticket);
              if (existingIndex == -1) {
                _history.insert(
                  0,
                  TransferItem(
                    isSend: true,
                    path: _sendPath!,
                    ticket: ticket,
                    status: 'Sharing',
                    size: BigInt.zero,
                    timestamp: DateTime.now(),
                    files: [_sendPath!],
                  ),
                );
              }
            });
          },
          failed: (error) {
            setState(() {
              _isSending = false;
              _isImporting = false;
              _sendError = error;
              _sendStatus = 'Failed: $error';
            });
          },
        );
      }, onError: (e) {
        setState(() {
          _isSending = false;
          _isImporting = false;
          _sendError = e.toString();
          _sendStatus = 'Error: $e';
        });
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _isImporting = false;
        _sendError = e.toString();
        _sendStatus = 'Error: $e';
      });
    }
  }

  Future<void> _stopSharing() async {
    await _sendSub?.cancel();
    try {
      await stopSend();
    } catch (_) {}

    setState(() {
      if (_sendTicket != null) {
        final index =
            _history.indexWhere((item) => item.ticket == _sendTicket);
        if (index != -1) {
          final old = _history[index];
          _history[index] = old.copyWith(status: 'Stopped');
        }
      }
      _isSending = false;
      _isImporting = false;
      _sendTicket = null;
      _sendStatus = '';
      _sendProgress = 0.0;
    });
  }

  void _startMetricsTimer() {
    _metricsTimer?.cancel();
    _receiveStartTime = DateTime.now();
    _lastSpeedCalcTime = DateTime.now();
    _lastDownloadedBytes = BigInt.zero;
    _receiveSpeed = '0 MB/s';
    _elapsedTime = '00:00';

    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isReceiving || _receiveStartTime == null) return;
      final elapsed = DateTime.now().difference(_receiveStartTime!);
      final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
      final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _elapsedTime = '$minutes:$seconds';
      });
    });
  }

  void _stopMetricsTimer() {
    _metricsTimer?.cancel();
    _metricsTimer = null;
  }

  Future<void> _startDownloading() async {
    final ticketStr = _ticketController.text.trim();
    final dest = _destController.text.trim();
    if (ticketStr.isEmpty || dest.isEmpty) return;

    if (dest == '/' || dest.startsWith('/sys') || dest.startsWith('/proc')) {
      setState(() {
        _receiveError =
            'Cannot save to root or system directories. Please choose a valid writable folder.';
      });
      return;
    }

    setState(() {
      _isReceiving = true;
      _receiveStatus = 'Connecting...';
      _receiveProgress = 0.0;
      _receiveError = null;
    });

    _startMetricsTimer();

    try {
      final destDir = Directory(dest);
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }
      final temp = await getTemporaryDirectory();
      _receiveSub = startReceive(
        ticketStr: ticketStr,
        tempDir: temp.path,
        destinationDir: dest,
      ).listen((progress) {
        progress.when(
          connecting: () {
            setState(() {
              _receiveStatus = 'Connecting to peer...';
            });
          },
          connected: () {
            setState(() {
              _receiveStatus = 'Connected. Handshaking...';
            });
          },
          retrievingMetadata: () {
            setState(() {
              _receiveStatus = 'Retrieving metadata...';
            });
          },
          downloading: (bytesDownloaded, totalBytes, percentage) {
            final now = DateTime.now();
            if (_lastSpeedCalcTime != null) {
              final msDiff = now.difference(_lastSpeedCalcTime!).inMilliseconds;
              if (msDiff >= 800) {
                final bytesDiff = bytesDownloaded - _lastDownloadedBytes;
                if (bytesDiff >= BigInt.zero && msDiff > 0) {
                  final bytesPerSec =
                      (bytesDiff.toDouble() / (msDiff / 1000.0));
                  final mbPerSec = bytesPerSec / (1024.0 * 1024.0);
                  _receiveSpeed = '${mbPerSec.toStringAsFixed(1)} MB/s';
                }
                _lastSpeedCalcTime = now;
                _lastDownloadedBytes = bytesDownloaded;
              }
            }

            setState(() {
              _receiveStatus =
                  'Downloading: ${StorageService.formatBytes(bytesDownloaded)} / ${StorageService.formatBytes(totalBytes)}';
              _receiveProgress = percentage / 100.0;
            });
          },
          downloadDone: (totalBytes) {
            setState(() {
              _receiveStatus = 'Download complete. Exporting...';
              _receiveProgress = 1.0;
              _receiveSpeed = null;
            });
          },
          exporting: (fileName, bytesExported, bytesTotal) {
            setState(() {
              _receiveStatus = 'Exporting: $fileName';
              _receiveProgress = bytesTotal > BigInt.zero
                  ? bytesExported.toDouble() / bytesTotal.toDouble()
                  : 0.0;
            });
          },
          finished: (totalFiles, totalBytes, exportedPaths) {
            _stopMetricsTimer();
            if (exportedPaths.isNotEmpty) {
              StorageService.scanFiles(exportedPaths);
            }
            setState(() {
              _isReceiving = false;
              _receiveStatus = 'Success! Saved to $dest';
              _receiveProgress = 1.0;
              _receiveSpeed = null;

              _history.insert(
                0,
                TransferItem(
                  isSend: false,
                  path: dest,
                  ticket: ticketStr,
                  status: 'Completed',
                  size: totalBytes,
                  timestamp: DateTime.now(),
                  files: exportedPaths,
                ),
              );
            });
          },
          failed: (error) {
            _stopMetricsTimer();
            setState(() {
              _isReceiving = false;
              _receiveError = error;
              _receiveStatus = 'Failed: $error';
              _receiveSpeed = null;
            });
          },
        );
      }, onError: (e) {
        _stopMetricsTimer();
        setState(() {
          _isReceiving = false;
          _receiveError = e.toString();
          _receiveStatus = 'Error: $e';
          _receiveSpeed = null;
        });
      });
    } catch (e) {
      _stopMetricsTimer();
      setState(() {
        _isReceiving = false;
        _receiveError = e.toString();
        _receiveStatus = 'Error: $e';
        _receiveSpeed = null;
      });
    }
  }

  Future<void> _cancelDownloading() async {
    _stopMetricsTimer();
    await _receiveSub?.cancel();
    try {
      await cancelReceive();
    } catch (_) {}

    setState(() {
      _isReceiving = false;
      _receiveStatus = 'Cancelled';
      _receiveProgress = 0.0;
      _receiveSpeed = null;
    });
  }

  void _copyLogsToClipboard() {
    if (_debugLogs.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _debugLogs.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.emeraldAccentColor),
            SizedBox(width: 8),
            Text('Logs copied to clipboard'),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.emeraldAccentColor),
            SizedBox(width: 8),
            Text('Ticket copied to clipboard'),
          ],
        ),
      ),
    );
  }

  void _shareTicket(String text) {
    // ignore: deprecated_member_use
    Share.share(text, subject: 'Sendme P2P Ticket');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SendTab(
                      sendPath: _sendPath,
                      folderStats: _folderStats,
                      isSending: _isSending,
                      isImporting: _isImporting,
                      sendTicket: _sendTicket,
                      sendStatus: _sendStatus,
                      sendProgress: _sendProgress,
                      sendError: _sendError,
                      onPickFile: _pickSendFile,
                      onPickFolder: _pickSendFolder,
                      onClearSelection: () {
                        setState(() {
                          _sendPath = null;
                          _folderStats = null;
                          _sendError = null;
                        });
                      },
                      onStartSharing: _startSharing,
                      onStopSharing: _stopSharing,
                      onCopyTicket: _copyToClipboard,
                      onShareTicket: _shareTicket,
                    ),
                    ReceiveTab(
                      ticketController: _ticketController,
                      destController: _destController,
                      isReceiving: _isReceiving,
                      receiveStatus: _receiveStatus,
                      receiveProgress: _receiveProgress,
                      receiveSpeed: _receiveSpeed,
                      elapsedTime: _elapsedTime,
                      receiveError: _receiveError,
                      onPickDestFolder: _pickDestFolder,
                      onShowStorageInfo: _showStorageInfoDialog,
                      onStartDownloading: _startDownloading,
                      onCancelDownloading: _cancelDownloading,
                    ),
                    HistoryTab(
                      history: _history,
                      onClearHistory: () => setState(() => _history.clear()),
                      onDeleteItem: (index) =>
                          setState(() => _history.removeAt(index)),
                    ),
                    LogsTab(
                      logs: _debugLogs,
                      scrollController: _logsScrollController,
                      onCopyLogs: _copyLogsToClipboard,
                      onClearLogs: () => setState(() => _debugLogs.clear()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.logoGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_horizontal_circle_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SENDME',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Iroh Peer-to-Peer Portal',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Status badge
          _isSending || _isReceiving
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.emeraldColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulseDot(color: AppTheme.emeraldAccentColor),
                      const SizedBox(width: 6),
                      Text(
                        _isSending ? 'SHARING' : 'DOWNLOADING',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.emeraldAccentColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'IDLE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[500],
        labelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            text: 'Share Files',
            icon: Icon(Icons.send_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            text: 'Receive Files',
            icon: Icon(Icons.download_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            text: 'History',
            icon: Icon(Icons.history_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            text: 'Debug Logs',
            icon: Icon(Icons.terminal_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
        ],
      ),
    );
  }
}
