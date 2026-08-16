class TransferItem {
  final bool isSend;
  final String path;
  final String ticket;
  final String status;
  final BigInt size;
  final DateTime timestamp;
  final List<String> files;

  const TransferItem({
    required this.isSend,
    required this.path,
    required this.ticket,
    required this.status,
    required this.size,
    required this.timestamp,
    required this.files,
  });

  TransferItem copyWith({
    bool? isSend,
    String? path,
    String? ticket,
    String? status,
    BigInt? size,
    DateTime? timestamp,
    List<String>? files,
  }) {
    return TransferItem(
      isSend: isSend ?? this.isSend,
      path: path ?? this.path,
      ticket: ticket ?? this.ticket,
      status: status ?? this.status,
      size: size ?? this.size,
      timestamp: timestamp ?? this.timestamp,
      files: files ?? this.files,
    );
  }

  Map<String, dynamic> toJson() => {
        'isSend': isSend,
        'path': path,
        'ticket': ticket,
        'status': status,
        'size': size.toString(),
        'timestamp': timestamp.toIso8601String(),
        'files': files,
      };

  static TransferItem fromJson(Map<String, dynamic> json) => TransferItem(
        isSend: json['isSend'] as bool,
        path: json['path'] as String,
        ticket: json['ticket'] as String,
        status: json['status'] as String,
        size: BigInt.parse(json['size'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        files: (json['files'] as List).cast<String>(),
      );
}
