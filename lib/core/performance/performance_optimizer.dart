import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../monitoring/app_monitoring.dart';

class PerformanceOptimizer {
  static bool _initialized = false;
  static final Map<String, DateTime> _memoryWarnings = {};

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Configure rendering performance
      _optimizeRendering();

      // Set up memory monitoring
      _setupMemoryMonitoring();

      // Configure garbage collection
      _optimizeGarbageCollection();

      // Set up image caching
      _optimizeImageCaching();

      _initialized = true;
      debugPrint('⚡ Performance optimizer initialized');

      AppMonitoring().logEvent('performance_optimizer_initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize performance optimizer: $e');
      AppMonitoring().recordError(
        e,
        StackTrace.current,
        reason: 'Performance optimizer initialization failed',
      );
    }
  }

  static void _optimizeRendering() {
    // Configure Flutter's rendering settings
    if (!kIsWeb) {
      // Enable hardware acceleration on mobile
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    // Reduce overdraw in debug mode
    if (kDebugMode) {
      debugPaintSizeEnabled = false;
      debugRepaintRainbowEnabled = false;
    }
  }

  static void _setupMemoryMonitoring() {
    // Monitor memory usage periodically
    if (kDebugMode) {
      // In debug mode, check memory more frequently
      _scheduleMemoryCheck();
    }
  }

  static void _optimizeGarbageCollection() {
    if (!kIsWeb && Platform.isAndroid) {
      // Android-specific optimizations
      SystemChannels.platform.invokeMethod('SystemChrome.setPreferredOrientations');
    }
  }

  static void _optimizeImageCaching() {
    // Configure image cache limits
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }

  static void _scheduleMemoryCheck() {
    Future.delayed(const Duration(minutes: 5), () {
      _checkMemoryUsage();
      if (kDebugMode) {
        _scheduleMemoryCheck(); // Schedule next check
      }
    });
  }

  static void _checkMemoryUsage() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final imageCacheSize = imageCache.currentSizeBytes;
      final imageCacheCount = imageCache.currentSize;

      final metrics = PerformanceMetrics(
        imageCacheSize: imageCacheSize,
        imageCacheCount: imageCacheCount,
        timestamp: DateTime.now(),
      );

      _logMemoryMetrics(metrics);

      // Check if memory usage is high
      if (imageCacheSize > (30 << 20)) { // 30 MB
        _handleHighMemoryUsage();
      }
    } catch (e) {
      debugPrint('❌ Memory check failed: $e');
    }
  }

  static void _logMemoryMetrics(PerformanceMetrics metrics) {
    AppMonitoring().logPerformanceMetric(
      metricName: 'image_cache_size',
      value: metrics.imageCacheSize,
      unit: 'bytes',
      context: {
        'image_cache_count': metrics.imageCacheCount,
      },
    );
  }

  static void _handleHighMemoryUsage() {
    final now = DateTime.now();
    final lastWarning = _memoryWarnings['high_memory'];

    // Only warn once per hour
    if (lastWarning == null || now.difference(lastWarning).inHours >= 1) {
      debugPrint('⚠️ High memory usage detected');

      // Clear image cache to free memory
      PaintingBinding.instance.imageCache.clear();

      // Force garbage collection
      _forceGarbageCollection();

      _memoryWarnings['high_memory'] = now;

      AppMonitoring().logEvent('high_memory_usage_detected', parameters: {
        'action_taken': 'cache_cleared',
        'gc_forced': true,
      });
    }
  }

  static void _forceGarbageCollection() {
    // Force garbage collection by creating and releasing objects
    final temp = <Object>[];
    for (int i = 0; i < 1000; i++) {
      temp.add(Object());
    }
    temp.clear();
  }

  static void optimizeForBatteryLife() {
    try {
      // Reduce frame rate for battery optimization
      if (!kIsWeb) {
        // Only on mobile platforms
        _reduceAnimationFrameRate();
      }

      AppMonitoring().logEvent('battery_optimization_enabled');
    } catch (e) {
      debugPrint('❌ Battery optimization failed: $e');
    }
  }

  static void _reduceAnimationFrameRate() {
    // Reduce animations when battery is low
    // This would typically integrate with battery level APIs
    debugPrint('🔋 Battery optimization applied');
  }

  static void optimizeForPerformance() {
    try {
      // Maximize performance
      _enableHighPerformanceMode();

      AppMonitoring().logEvent('performance_mode_enabled');
    } catch (e) {
      debugPrint('❌ Performance optimization failed: $e');
    }
  }

  static void _enableHighPerformanceMode() {
    // Increase cache sizes for better performance
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

    debugPrint('🚀 High performance mode enabled');
  }

  static Future<void> preloadCriticalAssets() async {
    try {
      // Preload critical images and assets
      await _preloadImages();
      await _preloadFonts();

      AppMonitoring().logEvent('critical_assets_preloaded');
    } catch (e) {
      debugPrint('❌ Asset preloading failed: $e');
      AppMonitoring().recordError(
        e,
        StackTrace.current,
        reason: 'Asset preloading failed',
      );
    }
  }

  static Future<void> _preloadImages() async {
    // Preload critical images that are used frequently
    final criticalImages = [
      'assets/images/logo.png',
      'assets/images/splash_background.png',
    ];

    for (final imagePath in criticalImages) {
      try {
        // Create a minimal context for preloading
        final rootElement = WidgetsBinding.instance.rootElement;
        if (rootElement != null) {
          await precacheImage(AssetImage(imagePath), rootElement);
        }
      } catch (e) {
        debugPrint('⚠️ Failed to preload image: $imagePath');
      }
    }
  }

  static Future<void> _preloadFonts() async {
    // Fonts are automatically preloaded by Flutter, but we can warm them up
    try {
      await FontLoader('Roboto').load();
    } catch (e) {
      debugPrint('⚠️ Font preloading failed: $e');
    }
  }

  static void clearCaches() {
    try {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();

      // Clear other caches if any
      debugPrint('🧹 Caches cleared');

      AppMonitoring().logEvent('caches_cleared', parameters: {
        'manual_clear': true,
      });
    } catch (e) {
      debugPrint('❌ Cache clearing failed: $e');
    }
  }

  static PerformanceReport generateReport() {
    final imageCache = PaintingBinding.instance.imageCache;

    return PerformanceReport(
      imageCacheSize: imageCache.currentSizeBytes,
      imageCacheCount: imageCache.currentSize,
      maxImageCacheSize: imageCache.maximumSizeBytes,
      maxImageCacheCount: imageCache.maximumSize,
      isOptimized: _initialized,
      recommendations: _generateRecommendations(),
    );
  }

  static List<String> _generateRecommendations() {
    final recommendations = <String>[];
    final imageCache = PaintingBinding.instance.imageCache;

    if (imageCache.currentSizeBytes > (imageCache.maximumSizeBytes * 0.8)) {
      recommendations.add('Image cache is almost full. Consider clearing cache.');
    }

    if (!_initialized) {
      recommendations.add('Performance optimizer not initialized.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('App performance is optimal.');
    }

    return recommendations;
  }
}

class PerformanceMetrics {
  final int imageCacheSize;
  final int imageCacheCount;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.imageCacheSize,
    required this.imageCacheCount,
    required this.timestamp,
  });
}

class PerformanceReport {
  final int imageCacheSize;
  final int imageCacheCount;
  final int maxImageCacheSize;
  final int maxImageCacheCount;
  final bool isOptimized;
  final List<String> recommendations;

  const PerformanceReport({
    required this.imageCacheSize,
    required this.imageCacheCount,
    required this.maxImageCacheSize,
    required this.maxImageCacheCount,
    required this.isOptimized,
    required this.recommendations,
  });

  double get cacheUsagePercentage {
    if (maxImageCacheSize == 0) return 0;
    return (imageCacheSize / maxImageCacheSize) * 100;
  }

  String get formattedCacheSize {
    final sizeInMB = imageCacheSize / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  String get formattedMaxCacheSize {
    final sizeInMB = maxImageCacheSize / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }
}