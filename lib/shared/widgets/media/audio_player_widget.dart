import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../common/loading_widget.dart';
import '../../themes/colors.dart';

/// Audio Player Widget - Reusable audio player component
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? title;
  final bool showControls;
  final bool autoPlay;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.title,
    this.showControls = true,
    this.autoPlay = false,
    this.onPlay,
    this.onPause,
    this.onComplete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _audioPlayer.setSourceUrl(widget.audioUrl);

      _audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _duration = duration;
        });
      });

      _audioPlayer.onPositionChanged.listen((position) {
        setState(() {
          _position = position;
        });
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });

        if (state == PlayerState.completed) {
          widget.onComplete?.call();
        }
      });

      if (widget.autoPlay) {
        await _play();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _play() async {
    try {
      await _audioPlayer.resume();
      widget.onPlay?.call();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _pause() async {
    try {
      await _audioPlayer.pause();
      widget.onPause?.call();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: LoadingWidget()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Progress bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2 * 255),
          ),
          child: Slider(
            value: _duration.inMilliseconds > 0
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              final position = Duration(
                milliseconds: (value * _duration.inMilliseconds).round(),
              );
              _seek(position);
            },
          ),
        ),
        const SizedBox(height: 8),
        // Time display and controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _isPlaying ? _pause : _play,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ],
            ),
            Text(
              _formatDuration(_duration),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Compact Audio Player - Minimal audio player for lists
class CompactAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String title;
  final double? progress;
  final VoidCallback? onTap;

  const CompactAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.title,
    this.progress,
    this.onTap,
  });

  @override
  State<CompactAudioPlayer> createState() => _CompactAudioPlayerState();
}

class _CompactAudioPlayerState extends State<CompactAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing compact audio player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap ?? _togglePlayback,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Play button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isInitialized
                  ? IconButton(
                      onPressed: _togglePlayback,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    )
                  : const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.progress != null) ...[
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('Error toggling audio playback: $e');
    }
  }
}
