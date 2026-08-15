import 'dart:io';
import 'package:flutter/services.dart';

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
  static String formatBytes(dynamic bytes) {
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
}
