import 'package:equatable/equatable.dart';

/// Types of sync operations
enum SyncOperationType {
  insert,
  update,
  delete,
}

/// Status of sync operations
enum SyncStatus {
  pending,
  inProgress,
  success,
  failed,
}

/// Represents a sync operation to be queued and executed
class SyncOperation extends Equatable {
  final String id;
  final SyncOperationType operationType;
  final String tableName;
  final String recordId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncStatus status;
  final int retryCount;
  final String? errorMessage;

  const SyncOperation({
    required this.id,
    required this.operationType,
    required this.tableName,
    required this.recordId,
    required this.data,
    required this.timestamp,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
  });

  /// Create a copy with modified fields
  SyncOperation copyWith({
    String? id,
    SyncOperationType? operationType,
    String? tableName,
    String? recordId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    SyncStatus? status,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationType': operationType.name,
      'tableName': tableName,
      'recordId': recordId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      operationType: SyncOperationType.values.firstWhere(
        (e) => e.name == json['operationType'],
        orElse: () => SyncOperationType.update,
      ),
      tableName: json['tableName'] as String,
      recordId: json['recordId'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        operationType,
        tableName,
        recordId,
        data,
        timestamp,
        status,
        retryCount,
        errorMessage,
      ];
}