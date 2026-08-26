import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/src/models/transfer_item.dart';

void main() {
  group('TransferItem Tests', () {
    test('TransferItem JSON serialization & deserialization', () {
      final now = DateTime.now();
      final item = TransferItem(
        isSend: true,
        path: '/storage/emulated/0/Download/test.pdf',
        ticket: 'blob123ticketxyz',
        status: 'Completed',
        size: BigInt.from(1024567),
        timestamp: now,
        files: ['/storage/emulated/0/Download/test.pdf'],
      );

      final json = item.toJson();
      expect(json['isSend'], isTrue);
      expect(json['path'], equals('/storage/emulated/0/Download/test.pdf'));
      expect(json['ticket'], equals('blob123ticketxyz'));
      expect(json['status'], equals('Completed'));
      expect(json['size'], equals('1024567'));

      final restored = TransferItem.fromJson(json);
      expect(restored.isSend, isTrue);
      expect(restored.path, equals(item.path));
      expect(restored.ticket, equals(item.ticket));
      expect(restored.status, equals(item.status));
      expect(restored.size, equals(item.size));
      expect(restored.files, equals(item.files));
    });

    test('TransferItem copyWith creates modified instance', () {
      final item = TransferItem(
        isSend: false,
        path: '/downloads/document.docx',
        ticket: 'ticket_abc',
        status: 'Downloading',
        size: BigInt.from(5000),
        timestamp: DateTime.now(),
        files: [],
      );

      final updated = item.copyWith(status: 'Completed');
      expect(updated.status, equals('Completed'));
      expect(updated.isSend, equals(item.isSend));
      expect(updated.path, equals(item.path));
    });
  });
}
