import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

/// Service for handling audio and video playback
class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};

  /// Play audio from URL
  Future<AudioPlayer> playAudio(String url, {String? id}) async {
    final playerId = id ?? url;
    final player = AudioPlayer();

    try {
      await player.setSourceUrl(url);
      await player.resume();
      _audioPlayers[playerId] = player;

      // Remove from map when playback completes
      player.onPlayerComplete.listen((_) {
        _audioPlayers.remove(playerId);
      });

      return player;
    } catch (e) {
      await player.dispose();
      rethrow;
    }
  }

  /// Pause audio
  Future<void> pauseAudio(String id) async {
    final player = _audioPlayers[id];
    if (player != null) {
      await player.pause();
    }
  }

  /// Stop audio
  Future<void> stopAudio(String id) async {
    final player = _audioPlayers[id];
    if (player != null) {
      await player.stop();
      await player.dispose();
      _audioPlayers.remove(id);
    }
  }

  /// Get audio position
  Future<Duration?> getAudioPosition(String id) async {
    final player = _audioPlayers[id];
    if (player != null) {
      return await player.getCurrentPosition();
    }
    return null;
  }

  /// Get audio duration
  Future<Duration?> getAudioDuration(String id) async {
    final player = _audioPlayers[id];
    if (player != null) {
      return await player.getDuration();
    }
    return null;
  }

  /// Seek audio
  Future<void> seekAudio(String id, Duration position) async {
    final player = _audioPlayers[id];
    if (player != null) {
      await player.seek(position);
    }
  }

  /// Initialize video player
  Future<VideoPlayerController> initializeVideo(String url, {String? id}) async {
    final controllerId = id ?? url;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    await controller.initialize();
    _videoControllers[controllerId] = controller;

    return controller;
  }

  /// Play video
  Future<void> playVideo(String id) async {
    final controller = _videoControllers[id];
    if (controller != null) {
      await controller.play();
    }
  }

  /// Pause video
  Future<void> pauseVideo(String id) async {
    final controller = _videoControllers[id];
    if (controller != null) {
      await controller.pause();
    }
  }

  /// Stop video
  Future<void> stopVideo(String id) async {
    final controller = _videoControllers[id];
    if (controller != null) {
      await controller.pause();
      await controller.seekTo(Duration.zero);
    }
  }

  /// Dispose video controller
  Future<void> disposeVideo(String id) async {
    final controller = _videoControllers[id];
    if (controller != null) {
      await controller.dispose();
      _videoControllers.remove(id);
    }
  }

  /// Get video controller
  VideoPlayerController? getVideoController(String id) {
    return _videoControllers[id];
  }

  /// Dispose all media players
  Future<void> disposeAll() async {
    for (final player in _audioPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();

    for (final controller in _videoControllers.values) {
      await controller.dispose();
    }
    _videoControllers.clear();
  }
}