import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/transfer_item.dart';

class FolderStats {
  final int fileCount;
  final int totalBytes;

  const FolderStats({required this.fileCount, required this.totalBytes});
}

class StorageService {
  static const MethodChannel _channel =
      MethodChannel('com.example.my_app/storage');

  /// Check whether the app has external storage permissions (or All Files Access on Android 11+).
  static Future<bool> checkStoragePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? granted =
          await _channel.invokeMethod<bool>('checkStoragePermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request storage permission from the user (launches All Files Access settings or runtime permission).
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('requestStoragePermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Trigger Android MediaScanner so downloaded files show up in Gallery/Files apps.
  static Future<void> scanFiles(List<String> paths) async {
    if (!Platform.isAndroid || paths.isEmpty) return;
    try {
      await _channel.invokeMethod('scanFiles', {'paths': paths});
    } catch (_) {}
  }

  /// Launch Android system intent to open a folder.
  static Future<bool> openFolder(String path) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('openFolder', {'path': path});
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Scan a folder to compute total files and total byte size.
  static Future<FolderStats> inspectFolder(String folderPath) async {
    int count = 0;
    int totalBytes = 0;
    try {
      final dir = Directory(folderPath);
      if (await dir.exists()) {
        await for (final entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            count++;
            try {
              totalBytes += await entity.length();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    return FolderStats(fileCount: count, totalBytes: totalBytes);
  }

  /// Format dynamic byte values (BigInt, int, num, double) into human readable strings.
  static String formatBytes(dynamic bytes) {    if (bytes == null) return '0 B';
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

  static Future<File> _historyFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/transfer_history.json');
  }

  /// Load persisted transfer history. A missing history file yields an empty
  /// list; read, parse, and schema failures propagate to the caller.
  static Future<List<TransferItem>> loadHistory() async {
    final file = await _historyFile();
    if (!await file.exists()) return [];
    final List<dynamic> data = jsonDecode(await file.readAsString()) as List;
    return data
        .map((e) => TransferItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Persist transfer history atomically: serialize to a temporary file next
  /// to the live one, then rename over it, so a failed write preserves the
  /// last valid history. Write failures propagate to the caller.
  static Future<void> saveHistory(List<TransferItem> items) async {
    final file = await _historyFile();
    final tempFile = File('${file.path}.tmp');
    await tempFile
        .writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
    try {
      await tempFile.rename(file.path);
    } catch (_) {
      try {
        await tempFile.delete();
      } catch (_) {}
      rethrow;
    }
  }
}
