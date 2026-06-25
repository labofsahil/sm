import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:my_app/src/rust/api/sendme.dart';
import 'package:my_app/src/rust/api/simple.dart';
import 'package:my_app/src/rust/frb_generated.dart';

const Color emeraldColor = Color(0xFF10B981);
const Color emeraldAccentColor = Color(0xFF34D399);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const SendmeApp());
}

class SendmeApp extends StatelessWidget {
  const SendmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sendme P2P Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF141417),
          error: Color(0xFFEF4444),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardPage(),
    );
  }
}

class TransferItem {
  final bool isSend;
  final String path;
  final String ticket;
  final String status;
  final BigInt size;
  final DateTime timestamp;

  TransferItem({
    required this.isSend,
    required this.path,
    required this.ticket,
    required this.status,
    required this.size,
    required this.timestamp,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Send state
  String? _sendPath;
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
      final docs = await getApplicationDocumentsDirectory();
      setState(() {
        _destController.text = docs.path;
      });
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        setState(() {
          _destController.text = downloads.path;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _logPollTimer?.cancel();
    _logsScrollController.dispose();
    _tabController.dispose();
    _sendSub?.cancel();
    _receiveSub?.cancel();
    _ticketController.dispose();
    _destController.dispose();
    super.dispose();
  }

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';
    double size;
    if (bytes is BigInt) {
      size = bytes.toDouble();
    } else if (bytes is num) {
      size = bytes.toDouble();
    } else {
      return '0 B';
    }
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  Future<void> _pickSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _sendPath = result.files.single.path;
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
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        setState(() {
          _sendPath = path;
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
      final path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        setState(() {
          _destController.text = path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking folder: $e')),
      );
    }
  }

  Future<void> _startSharing() async {
    if (_sendPath == null) return;
    
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
      _sendSub = startSend(path: _sendPath!, tempDir: temp.path).listen((progress) {
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
              
              final existingIndex = _history.indexWhere((item) => item.ticket == ticket);
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
        final index = _history.indexWhere((item) => item.ticket == _sendTicket);
        if (index != -1) {
          final old = _history[index];
          _history[index] = TransferItem(
            isSend: old.isSend,
            path: old.path,
            ticket: old.ticket,
            status: 'Stopped',
            size: old.size,
            timestamp: old.timestamp,
          );
        }
      }
      _isSending = false;
      _isImporting = false;
      _sendTicket = null;
      _sendStatus = '';
      _sendProgress = 0.0;
    });
  }

  Future<void> _startDownloading() async {
    final ticketStr = _ticketController.text.trim();
    final dest = _destController.text.trim();
    if (ticketStr.isEmpty || dest.isEmpty) return;

    setState(() {
      _isReceiving = true;
      _receiveStatus = 'Connecting...';
      _receiveProgress = 0.0;
      _receiveError = null;
    });

    try {
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
            setState(() {
              _receiveStatus = 'Downloading: ${_formatBytes(bytesDownloaded)} / ${_formatBytes(totalBytes)}';
              _receiveProgress = percentage / 100.0;
            });
          },
          downloadDone: (totalBytes) {
            setState(() {
              _receiveStatus = 'Download complete. Exporting...';
              _receiveProgress = 1.0;
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
          finished: (totalFiles, totalBytes) {
            setState(() {
              _isReceiving = false;
              _receiveStatus = 'Success! Saved to $dest';
              _receiveProgress = 1.0;
              
              _history.insert(
                0,
                TransferItem(
                  isSend: false,
                  path: dest,
                  ticket: ticketStr,
                  status: 'Completed',
                  size: totalBytes,
                  timestamp: DateTime.now(),
                ),
              );
            });
          },
          failed: (error) {
            setState(() {
              _isReceiving = false;
              _receiveError = error;
              _receiveStatus = 'Failed: $error';
            });
          },
        );
      }, onError: (e) {
        setState(() {
          _isReceiving = false;
          _receiveError = e.toString();
          _receiveStatus = 'Error: $e';
        });
      });
    } catch (e) {
      setState(() {
        _isReceiving = false;
        _receiveError = e.toString();
        _receiveStatus = 'Error: $e';
      });
    }
  }

  Future<void> _cancelDownloading() async {
    await _receiveSub?.cancel();
    try {
      await cancelReceive();
    } catch (_) {}

    setState(() {
      _isReceiving = false;
      _receiveStatus = 'Cancelled';
      _receiveProgress = 0.0;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('Ticket copied to clipboard'),
          ],
        ),
        backgroundColor: Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareTicket(String text) {
    Share.share(text, subject: 'Sendme P2P Ticket');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F0F12),
                Color(0xFF08080A),
              ],
            ),
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
                    _buildSendTab(),
                    _buildReceiveTab(),
                    _buildHistoryTab(),
                    _buildLogsTab(),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
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
          // Status indicator
          _isSending || _isReceiving
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: emeraldColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: emeraldColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _PulseDot(color: emeraldAccentColor),
                      const SizedBox(width: 6),
                      Text(
                        _isSending ? 'SHARING' : 'DOWNLOADING',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: emeraldAccentColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24242A)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[500],
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
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

  Widget _buildSendTab() {
    if (_isSending) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildActiveSendCard(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSendDropZone(),
          const SizedBox(height: 24),
          if (_sendPath != null) ...[
            _buildFileDetailCard(),
            const SizedBox(height: 28),
            _buildActionGradientButton(
              onPressed: _startSharing,
              text: 'Generate Share Link',
              icon: Icons.offline_bolt_rounded,
            ),
          ],
          if (_sendError != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(_sendError!),
          ],
        ],
      ),
    );
  }

  Widget _buildSendDropZone() {
    return GestureDetector(
      onTap: _pickSendFile,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF141418),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _sendPath != null ? const Color(0xFF6366F1) : const Color(0xFF24242A),
            width: 2,
            style: _sendPath != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF818CF8),
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
                  onPressed: _pickSendFile,
                  icon: const Icon(Icons.insert_drive_file_rounded, size: 16),
                  label: const Text('Pick File'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _pickSendFolder,
                  icon: const Icon(Icons.folder_open_rounded, size: 16),
                  label: const Text('Pick Folder'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileDetailCard() {
    final name = _sendPath!.split('/').last;
    final isFolder = !name.contains('.');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24242A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
              color: const Color(0xFF06B6D4),
              size: 24,
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
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _sendPath!,
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
          IconButton(
            onPressed: () {
              setState(() {
                _sendPath = null;
                _sendError = null;
              });
            },
            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSendCard() {
    final fileName = _sendPath?.split('/').last ?? 'File';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF24242A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.03),
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
                        color: const Color(0xFF818CF8),
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
              if (_isImporting)
                const SpinKitRing(
                  color: Color(0xFF6366F1),
                  size: 24,
                  lineWidth: 2,
                )
              else
                const _PulseDot(color: emeraldAccentColor),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: const Color(0xFF24242A)),
          const SizedBox(height: 16),
          Text(
            _sendStatus,
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
              value: _sendProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF0F0F12),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          if (_sendTicket != null) ...[
            const SizedBox(height: 24),
            Text(
              'SHARE TICKET',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey[500],
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF24242A)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _sendTicket!,
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: const Color(0xFF06B6D4),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _copyToClipboard(_sendTicket!),
                    icon: const Icon(Icons.content_copy_rounded, color: Colors.grey, size: 20),
                    tooltip: 'Copy Ticket',
                  ),
                  IconButton(
                    onPressed: () => _shareTicket(_sendTicket!),
                    icon: const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                    tooltip: 'Share',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recipient can download using this ticket.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _stopSharing,
            icon: const Icon(Icons.stop_rounded, size: 18),
            label: const Text('Stop Sharing'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveTab() {
    if (_isReceiving) {
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
              color: const Color(0xFF818CF8),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ticketController,
            label: 'Enter Share Ticket',
            hint: 'Paste the ticket string here...',
            icon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 18),
          _buildFolderField(),
          const SizedBox(height: 28),
          _buildActionGradientButton(
            onPressed: _startDownloading,
            text: 'Download Files',
            icon: Icons.download_rounded,
          ),
          if (_receiveError != null) ...[
            const SizedBox(height: 20),
            _buildErrorCard(_receiveError!),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveReceiveCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF24242A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.02),
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
                      color: const Color(0xFF22D3EE),
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
                color: Color(0xFF06B6D4),
                size: 24,
                lineWidth: 2,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: const Color(0xFF24242A)),
          const SizedBox(height: 16),
          Text(
            _receiveStatus,
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
              value: _receiveProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF0F0F12),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _cancelDownloading,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel Download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24242A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF818CF8), size: 20),
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
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24242A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.folder_open_rounded, color: Color(0xFF818CF8), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _destController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Destination Directory',
                labelStyle: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
              ),
            ),
          ),
          IconButton(
            onPressed: _pickDestFolder,
            icon: const Icon(Icons.folder_copy_rounded, color: Colors.grey, size: 20),
            tooltip: 'Browse',
          ),
        ],
      ),
    );
  }

  Widget _buildActionGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error Occurred',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF87171),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: GoogleFonts.inter(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, color: Colors.grey[700], size: 48),
            const SizedBox(height: 16),
            Text(
              'No transfer history yet',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final fileName = item.path.split('/').last;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141418),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF24242A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isSend 
                      ? const Color(0xFF6366F1).withOpacity(0.08)
                      : const Color(0xFF06B6D4).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isSend ? Icons.upload_rounded : Icons.download_rounded,
                  color: item.isSend ? const Color(0xFF818CF8) : const Color(0xFF22D3EE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.isSend ? 'Shared via P2P' : 'Downloaded to ${item.path}',
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'Sharing' || item.status == 'Completed'
                          ? emeraldColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: item.status == 'Sharing' || item.status == 'Completed'
                            ? emeraldAccentColor
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (item.size > BigInt.zero)
                    Text(
                      _formatBytes(item.size),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
          child: Row(
            children: [
              const Icon(Icons.terminal_rounded, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                'Rust Debug Logs',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text('${_debugLogs.length} lines', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => setState(() => _debugLogs.clear()),
                icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400], textStyle: GoogleFonts.inter(fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1E26)),
            ),
            child: _debugLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, color: Colors.grey[700], size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No logs yet.\nStart a send or receive to see Rust logs here.',
                          style: GoogleFonts.robotoMono(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _logsScrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _debugLogs.length,
                    itemBuilder: (ctx, i) {
                      final line = _debugLogs[i];
                      Color lineColor = Colors.grey[400]!;
                      if (line.contains('[ERROR]') || line.contains('error')) lineColor = const Color(0xFFEF4444);
                      else if (line.contains('[WARN]') || line.contains('warn')) lineColor = const Color(0xFFF59E0B);
                      else if (line.contains('[INFO]')) lineColor = const Color(0xFF34D399);
                      else if (line.contains('[DEBUG]')) lineColor = const Color(0xFF60A5FA);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(line, style: GoogleFonts.robotoMono(color: lineColor, fontSize: 11, height: 1.4)),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }


}
class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
