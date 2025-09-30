import 'package:equatable/equatable.dart';

enum SyncOperationType {
  dictionaryCreate,
  dictionaryUpdate,
  dictionaryDelete,
  progressUpdate,
  userProfileUpdate,
}

enum SyncStatus {
  pending,
  inProgress,
  completed,
  failed,
  retrying,
}

class SyncOperation extends Equatable {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final String? localId;
  final String? firebaseId;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final int maxRetries;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    this.localId,
    this.firebaseId,
    this.status = SyncStatus.pending,
    required this.createdAt,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.errorMessage,
    this.metadata = const {},
  });

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    Map<String, dynamic>? data,
    String? localId,
    String? firebaseId,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      localId: localId ?? this.localId,
      firebaseId: firebaseId ?? this.firebaseId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get canRetry => retryCount < maxRetries && status == SyncStatus.failed;
  bool get isExpired => DateTime.now().difference(createdAt).inDays > 7;
  bool get needsRetry => status == SyncStatus.failed && canRetry;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'localId': localId,
      'firebaseId': firebaseId,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      localId: json['localId'] as String?,
      firebaseId: json['firebaseId'] as String?,
      status: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 3,
      errorMessage: json['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? {},
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        data,
        localId,
        firebaseId,
        status,
        createdAt,
        lastAttemptAt,
        retryCount,
        maxRetries,
        errorMessage,
        metadata,
      ];
}