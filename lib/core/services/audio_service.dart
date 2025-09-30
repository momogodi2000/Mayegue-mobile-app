import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for audio recording and playback functionality
class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;

  Timer? _recordingTimer;
  StreamSubscription? _playerPositionSubscription;
  StreamSubscription? _playerDurationSubscription;
  StreamSubscription? _playerStateSubscription;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get hasRecording => _currentRecordingPath != null;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackPosition => _playbackPosition;
  Duration get playbackDuration => _playbackDuration;
  String? get currentRecordingPath => _currentRecordingPath;

  @override
  void dispose() {
    _stopRecording();
    _stopPlayback();
    _recordingTimer?.cancel();
    _playerPositionSubscription?.cancel();
    _playerDurationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  /// Check and request microphone permission
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Guide user to settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Start recording audio
  Future<bool> startRecording({
    String? customPath,
    AudioEncoder encoder = AudioEncoder.aacLc,
    int bitRate = 128000,
    int samplingRate = 44100,
  }) async {
    try {
      // Check permission
      final hasPermission = await checkMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      // Stop any current recording
      if (_isRecording) {
        await _stopRecording();
      }

      // Generate recording path
      _currentRecordingPath = customPath ?? await _generateRecordingPath();

      // Configure recording
      final config = RecordConfig(
        encoder: encoder,
        bitRate: bitRate,
        sampleRate: samplingRate,
        numChannels: 1, // Mono recording
      );

      // Start recording
      await _recorder.start(config, path: _currentRecordingPath!);

      _isRecording = true;
      _recordingDuration = Duration.zero;

      // Start timer for duration tracking
      _recordingTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _recordingDuration = Duration(milliseconds: timer.tick * 100);
        notifyListeners();
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    return await _stopRecording();
  }

  Future<String?> _stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();
      _isRecording = false;
      _recordingTimer?.cancel();

      if (path != null) {
        _currentRecordingPath = path;
      }

      notifyListeners();
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  /// Start playback of recorded audio
  Future<bool> startPlayback({String? audioPath}) async {
    try {
      final pathToPlay = audioPath ?? _currentRecordingPath;
      if (pathToPlay == null) {
        throw Exception('No audio file to play');
      }

      // Stop any current playback
      await _stopPlayback();

      // Set up listeners
      _setupPlaybackListeners();

      // Start playback
      await _player.play(DeviceFileSource(pathToPlay));
      _isPlaying = true;
      _isPaused = false;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting playback: $e');
      return false;
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    try {
      await _player.pause();
      _isPlaying = false;
      _isPaused = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing playback: $e');
    }
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    try {
      await _player.resume();
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resuming playback: $e');
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _stopPlayback();
  }

  Future<void> _stopPlayback() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _isPaused = false;
      _playbackPosition = Duration.zero;

      // Cancel subscriptions
      _playerPositionSubscription?.cancel();
      _playerDurationSubscription?.cancel();
      _playerStateSubscription?.cancel();

      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping playback: $e');
    }
  }

  /// Seek to specific position during playback
  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  /// Delete current recording
  Future<bool> deleteCurrentRecording() async {
    try {
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting recording: $e');
      return false;
    }
  }

  /// Set up playback event listeners
  void _setupPlaybackListeners() {
    // Position updates
    _playerPositionSubscription = _player.onPositionChanged.listen((position) {
      _playbackPosition = position;
      notifyListeners();
    });

    // Duration updates
    _playerDurationSubscription = _player.onDurationChanged.listen((duration) {
      _playbackDuration = duration;
      notifyListeners();
    });

    // Player state changes
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.stopped:
        case PlayerState.completed:
          _isPlaying = false;
          _isPaused = false;
          _playbackPosition = Duration.zero;
          break;
        case PlayerState.playing:
          _isPlaying = true;
          _isPaused = false;
          break;
        case PlayerState.paused:
          _isPlaying = false;
          _isPaused = true;
          break;
        case PlayerState.disposed:
          _isPlaying = false;
          _isPaused = false;
          _playbackPosition = Duration.zero;
          break;
      }
      notifyListeners();
    });
  }

  /// Generate unique recording file path
  Future<String> _generateRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.aac';
  }

  /// Get recording quality settings
  RecordingQuality getRecordingQuality(AudioQuality quality) {
    switch (quality) {
      case AudioQuality.low:
        return const RecordingQuality(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          samplingRate: 22050,
        );
      case AudioQuality.medium:
        return const RecordingQuality(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );
      case AudioQuality.high:
        return const RecordingQuality(
          encoder: AudioEncoder.aacLc,
          bitRate: 256000,
          samplingRate: 48000,
        );
    }
  }

  /// Analyze audio recording (basic implementation)
  Future<AudioAnalysis> analyzeRecording({String? audioPath}) async {
    final pathToAnalyze = audioPath ?? _currentRecordingPath;
    if (pathToAnalyze == null) {
      throw Exception('No audio file to analyze');
    }

    try {
      final file = File(pathToAnalyze);
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);

      // Basic analysis - in a real implementation, you would use
      // audio processing libraries or send to a speech analysis service
      return AudioAnalysis(
        duration: _recordingDuration,
        fileSizeBytes: fileSizeBytes,
        fileSizeMB: fileSizeMB,
        sampleRate: 44100, // Default from recording config
        bitRate: 128000, // Default from recording config
        quality: _getQualityFromBitRate(128000),
        path: pathToAnalyze,
      );
    } catch (e) {
      throw Exception('Failed to analyze audio: $e');
    }
  }

  AudioQuality _getQualityFromBitRate(int bitRate) {
    if (bitRate < 96000) return AudioQuality.low;
    if (bitRate < 192000) return AudioQuality.medium;
    return AudioQuality.high;
  }
}

/// Audio quality levels
enum AudioQuality { low, medium, high }

/// Recording quality configuration
class RecordingQuality {
  final AudioEncoder encoder;
  final int bitRate;
  final int samplingRate;

  const RecordingQuality({
    required this.encoder,
    required this.bitRate,
    required this.samplingRate,
  });
}

/// Audio analysis result
class AudioAnalysis {
  final Duration duration;
  final int fileSizeBytes;
  final double fileSizeMB;
  final int sampleRate;
  final int bitRate;
  final AudioQuality quality;
  final String path;

  const AudioAnalysis({
    required this.duration,
    required this.fileSizeBytes,
    required this.fileSizeMB,
    required this.sampleRate,
    required this.bitRate,
    required this.quality,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'duration': duration.inMilliseconds,
      'fileSizeBytes': fileSizeBytes,
      'fileSizeMB': fileSizeMB,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'quality': quality.name,
      'path': path,
    };
  }
}

/// Exception for audio service errors
class AudioServiceException implements Exception {
  final String message;
  final String? code;

  const AudioServiceException(this.message, {this.code});

  @override
  String toString() =>
      'AudioServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}
