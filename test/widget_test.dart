import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/src/theme/app_theme.dart';
import 'package:my_app/src/views/tabs/history_tab.dart';
import 'package:my_app/src/views/tabs/logs_tab.dart';
import 'package:my_app/src/views/tabs/receive_tab.dart';
import 'package:my_app/src/views/tabs/send_tab.dart';
import 'package:my_app/src/models/transfer_item.dart';

void main() {
  group('Widget Tests for Dashboard Tabs', () {
    testWidgets('SendTab displays select prompt and options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SendTab(
              sendPath: null,
              folderStats: null,
              isSending: false,
              isImporting: false,
              sendTicket: null,
              sendStatus: '',
              sendProgress: 0.0,
              sendError: null,
              onPickFile: () {},
              onPickFolder: () {},
              onClearSelection: () {},
              onStartSharing: () {},
              onStopSharing: () {},
              onCopyTicket: (_) {},
              onShareTicket: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select what you want to share'), findsOneWidget);
      expect(find.text('Pick File'), findsOneWidget);
      expect(find.text('Pick Folder'), findsOneWidget);
    });

    testWidgets('ReceiveTab displays input fields and download button', (WidgetTester tester) async {
      final ticketController = TextEditingController();
      final destController = TextEditingController(text: '/downloads/sendme');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReceiveTab(
              ticketController: ticketController,
              destController: destController,
              isReceiving: false,
              receiveStatus: '',
              receiveProgress: 0.0,
              receiveError: null,
              onPickDestFolder: () {},
              onShowStorageInfo: () {},
              onStartDownloading: () {},
              onCancelDownloading: () {},
            ),
          ),
        ),
      );

      expect(find.text('DOWNLOAD FROM PEER'), findsOneWidget);
      expect(find.text('Enter Share Ticket'), findsOneWidget);
      expect(find.text('Download Files'), findsOneWidget);
    });

    testWidgets('HistoryTab displays empty state when no transfers exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: HistoryTab(
              history: const [],
              onClearHistory: () {},
              onDeleteItem: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('No transfer history yet'), findsOneWidget);
    });

    testWidgets('HistoryTab displays transfer items and filters correctly', (WidgetTester tester) async {
      final history = [
        TransferItem(
          isSend: true,
          path: '/path/to/shared.zip',
          ticket: 'ticket1',
          status: 'Sharing',
          size: BigInt.from(2048),
          timestamp: DateTime.now(),
          files: [],
        ),
        TransferItem(
          isSend: false,
          path: '/path/to/downloaded.png',
          ticket: 'ticket2',
          status: 'Completed',
          size: BigInt.from(1024),
          timestamp: DateTime.now(),
          files: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: HistoryTab(
              history: history,
              onClearHistory: () {},
              onDeleteItem: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('shared.zip'), findsOneWidget);
      expect(find.text('downloaded.png'), findsOneWidget);
    });

    testWidgets('LogsTab displays logs and filters', (WidgetTester tester) async {
      final logs = [
        '[INFO][sendme] Node initialized successfully',
        '[ERROR][sendme] Failed to connect to peer',
      ];
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LogsTab(
              logs: logs,
              scrollController: scrollController,
              onCopyLogs: () {},
              onClearLogs: () {},
            ),
          ),
        ),
      );

      expect(find.text('Rust Debug Logs'), findsOneWidget);
      expect(find.textContaining('Node initialized successfully'), findsOneWidget);
      expect(find.textContaining('Failed to connect to peer'), findsOneWidget);
    });
  });
}
