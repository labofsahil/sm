import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

class FolderPickerModal extends StatefulWidget {
  final String? initialPath;

  const FolderPickerModal({super.key, this.initialPath});

  static Future<String?> show(BuildContext context, {String? initialPath}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FolderPickerModal(initialPath: initialPath),
    );
  }

  @override
  State<FolderPickerModal> createState() => _FolderPickerModalState();
}

class _FolderPickerModalState extends State<FolderPickerModal> {
  late Directory _currentDir;
  List<FileSystemEntity> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasPermission = true;

  final List<Map<String, String>> _shortcuts = [];

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  Future<void> _initDirectory() async {
    setState(() => _isLoading = true);

    _hasPermission = await StorageService.checkStoragePermission();

    // Prepare quick shortcuts
    _shortcuts.clear();
    if (Platform.isAndroid) {
      _shortcuts.addAll([
        {'label': 'Downloads', 'path': '/storage/emulated/0/Download'},
        {'label': 'Documents', 'path': '/storage/emulated/0/Documents'},
        {'label': 'DCIM / Photos', 'path': '/storage/emulated/0/DCIM'},
        {'label': 'Pictures', 'path': '/storage/emulated/0/Pictures'},
        {'label': 'Music', 'path': '/storage/emulated/0/Music'},
        {'label': 'Internal Storage', 'path': '/storage/emulated/0'},
      ]);
    } else {
      try {
        final docs = await getApplicationDocumentsDirectory();
        _shortcuts.add({'label': 'Documents', 'path': docs.path});
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          _shortcuts.add({'label': 'Downloads', 'path': downloads.path});
        }
      } catch (_) {}
    }

    String startPath = widget.initialPath ?? '';
    if (startPath.isEmpty || !await Directory(startPath).exists()) {
      if (Platform.isAndroid && await Directory('/storage/emulated/0/Download').exists()) {
        startPath = '/storage/emulated/0/Download';
      } else if (Platform.isAndroid && await Directory('/storage/emulated/0').exists()) {
        startPath = '/storage/emulated/0';
      } else {
        final appDoc = await getApplicationDocumentsDirectory();
        startPath = appDoc.path;
      }
    }

    _currentDir = Directory(startPath);
    await _loadCurrentDirectory();
  }

  Future<void> _loadCurrentDirectory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!await _currentDir.exists()) {
        setState(() {
          _errorMessage = 'Directory does not exist: ${_currentDir.path}';
          _entries = [];
          _isLoading = false;
        });
        return;
      }

      final List<FileSystemEntity> dirs = [];
      final List<FileSystemEntity> files = [];

      final stream = _currentDir.list(followLinks: false);
      await for (final entity in stream) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith('.')) continue; // ignore hidden
        if (entity is Directory) {
          dirs.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }

      dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

      setState(() {
        _entries = [...dirs, ...files];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot access directory: $e';
        _entries = [];
        _isLoading = false;
      });
    }
  }

  void _navigateTo(Directory dir) {
    setState(() {
      _currentDir = dir;
    });
    _loadCurrentDirectory();
  }

  void _navigateUp() {
    final parent = _currentDir.parent;
    if (parent.path != _currentDir.path) {
      _navigateTo(parent);
    }
  }

  Future<void> _requestPermission() async {
    await StorageService.requestStoragePermission();
    _hasPermission = await StorageService.checkStoragePermission();
    if (_hasPermission) {
      _loadCurrentDirectory();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final folderName = _currentDir.path.split(Platform.pathSeparator).last.isEmpty
        ? 'Root'
        : _currentDir.path.split(Platform.pathSeparator).last;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF101014),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF2E2E38), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open_rounded, color: Color(0xFF818CF8), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Folder to Share',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Navigate and pick any directory',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Permission warning if applicable
          if (!_hasPermission && Platform.isAndroid)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All Files Access required to browse all storage.',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _requestPermission,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Shortcut chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _shortcuts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final shortcut = _shortcuts[index];
                final isSelected = _currentDir.path == shortcut['path'];
                return ActionChip(
                  label: Text(shortcut['label']!),
                  avatar: Icon(
                    isSelected ? Icons.folder_rounded : Icons.folder_outlined,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF818CF8),
                  ),
                  backgroundColor: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF1E1E26),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[300],
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF2E2E3A),
                  ),
                  onPressed: () {
                    final target = Directory(shortcut['path']!);
                    _navigateTo(target);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Path & navigation bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16161C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF282834)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _currentDir.parent.path != _currentDir.path ? _navigateUp : null,
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  color: const Color(0xFF818CF8),
                  disabledColor: Colors.grey[700],
                  tooltip: 'Go to parent folder',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentDir.path,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Directory file list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_off_rounded, color: Color(0xFFEF4444), size: 40),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _requestPermission,
                                icon: const Icon(Icons.security_rounded, size: 16),
                                label: const Text('Check Permissions'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _entries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_open_rounded, color: Colors.grey[700], size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'This folder is empty',
                                  style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entity = _entries[index];
                              final isDir = entity is Directory;
                              final name = entity.path.split(Platform.pathSeparator).last;

                              return InkWell(
                                onTap: isDir ? () => _navigateTo(entity) : null,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDir
                                        ? const Color(0xFF1E1E26).withValues(alpha: 0.4)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isDir ? Icons.folder_rounded : Icons.insert_drive_file_outlined,
                                        color: isDir ? const Color(0xFF818CF8) : Colors.grey[500],
                                        size: 22,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: isDir ? FontWeight.w600 : FontWeight.normal,
                                            color: isDir ? Colors.white : Colors.grey[400],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isDir)
                                        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20)
                                      else
                                        FutureBuilder<FileStat>(
                                          future: entity.stat(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                _formatFileSize(snapshot.data!.size),
                                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF141418),
              border: Border(top: BorderSide(color: Color(0xFF24242E))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SELECTED FOLDER',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF818CF8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        folderName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _currentDir.path == '/' || _currentDir.path.isEmpty
                      ? null
                      : () => Navigator.pop(context, _currentDir.path),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Select Folder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
