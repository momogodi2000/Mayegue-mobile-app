import 'package:flutter/foundation.dart';

/// Performance configuration for the Mayegue app
class PerformanceConfig {
  // Database optimization
  static const int maxCacheSize = 100; // MB
  static const int maxLocalEntries = 10000;
  static const Duration syncBatchTimeout = Duration(seconds: 30);
  static const int maxConcurrentSyncs = 3;

  // Image optimization
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageCompressionQuality = 85;
  static const int thumbnailSize = 200;

  // Audio optimization
  static const int audioBitrate = 128; // kbps
  static const int audioSampleRate = 44100; // Hz
  static const Duration maxRecordingDuration = Duration(minutes: 5);

  // Network optimization
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int downloadChunkSize = 1024 * 1024; // 1MB

  // Memory management
  static const int maxMemoryUsage = 512; // MB
  static const int imagesCacheCount = 100;
  static const Duration cacheEvictionTime = Duration(hours: 1);

  // Background processing
  static const Duration backgroundSyncInterval = Duration(minutes: 15);
  static const int maxBackgroundTasks = 5;
  static const Duration backgroundTaskTimeout = Duration(minutes: 5);

  // UI performance
  static const int listViewCacheExtent = 500;
  static const int gridViewCacheExtent = 1000;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const bool enablePerformanceOverlay = kDebugMode;

  // Search optimization
  static const int searchResultsLimit = 50;
  static const Duration searchDebounceTime = Duration(milliseconds: 300);
  static const int minSearchQueryLength = 2;

  // Analytics batching
  static const int maxAnalyticsEvents = 50;
  static const Duration analyticsFlushInterval = Duration(minutes: 5);

  /// Get performance settings based on device capabilities
  static PerformanceSettings getOptimalSettings() {
    // Simple device capability detection
    final isLowEndDevice = _isLowEndDevice();

    return PerformanceSettings(
      enableAnimations: !isLowEndDevice,
      imageQuality: isLowEndDevice ? 70 : imageCompressionQuality,
      cacheSize: isLowEndDevice ? 50 : maxCacheSize,
      maxConcurrentOperations: isLowEndDevice ? 2 : maxConcurrentSyncs,
      enableBackgroundSync: !isLowEndDevice,
      enablePrefetching: !isLowEndDevice,
      enableImageCaching: true,
      enableAnalytics: true,
    );
  }

  /// Simple low-end device detection
  static bool _isLowEndDevice() {
    // This is a simplified check - in a real app, you might use
    // device_info_plus to get more detailed hardware information
    return kDebugMode ? false : false; // Assume decent devices for now
  }

  /// Performance monitoring configuration
  static const bool enablePerformanceMonitoring = !kDebugMode;
  static const Duration performanceReportInterval = Duration(minutes: 10);

  /// Memory pressure thresholds
  static const double memoryWarningThreshold = 0.8; // 80% of max
  static const double memoryCriticalThreshold = 0.95; // 95% of max

  /// Network quality detection
  static const Duration networkQualityCheckInterval = Duration(minutes: 1);
  static const int lowBandwidthThreshold = 1000; // 1 Mbps

  /// App lifecycle optimization
  static const Duration appStateCheckInterval = Duration(seconds: 30);
  static const Duration inactiveStateTimeout = Duration(minutes: 5);

  /// Error reporting limits
  static const int maxErrorReportsPerSession = 10;
  static const Duration errorReportCooldown = Duration(minutes: 1);
}

class PerformanceSettings {
  final bool enableAnimations;
  final int imageQuality;
  final int cacheSize;
  final int maxConcurrentOperations;
  final bool enableBackgroundSync;
  final bool enablePrefetching;
  final bool enableImageCaching;
  final bool enableAnalytics;

  const PerformanceSettings({
    required this.enableAnimations,
    required this.imageQuality,
    required this.cacheSize,
    required this.maxConcurrentOperations,
    required this.enableBackgroundSync,
    required this.enablePrefetching,
    required this.enableImageCaching,
    required this.enableAnalytics,
  });

  Map<String, dynamic> toJson() {
    return {
      'enableAnimations': enableAnimations,
      'imageQuality': imageQuality,
      'cacheSize': cacheSize,
      'maxConcurrentOperations': maxConcurrentOperations,
      'enableBackgroundSync': enableBackgroundSync,
      'enablePrefetching': enablePrefetching,
      'enableImageCaching': enableImageCaching,
      'enableAnalytics': enableAnalytics,
    };
  }

  factory PerformanceSettings.fromJson(Map<String, dynamic> json) {
    return PerformanceSettings(
      enableAnimations: json['enableAnimations'] ?? true,
      imageQuality: json['imageQuality'] ?? 85,
      cacheSize: json['cacheSize'] ?? 100,
      maxConcurrentOperations: json['maxConcurrentOperations'] ?? 3,
      enableBackgroundSync: json['enableBackgroundSync'] ?? true,
      enablePrefetching: json['enablePrefetching'] ?? true,
      enableImageCaching: json['enableImageCaching'] ?? true,
      enableAnalytics: json['enableAnalytics'] ?? true,
    );
  }
}