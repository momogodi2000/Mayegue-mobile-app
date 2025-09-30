import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../common/loading_widget.dart';
import '../../themes/colors.dart';

/// Video Player Widget - Reusable video player component
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool showControls;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final Function(Duration)? onPositionChanged;
  final Function(Duration)? onDurationChanged;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.title,
    this.showControls = true,
    this.autoPlay = false,
    this.loop = false,
    this.onPlay,
    this.onPause,
    this.onPositionChanged,
    this.onDurationChanged,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller.initialize();

      _controller.addListener(() {
        if (mounted) {
          setState(() {});
          widget.onPositionChanged?.call(_controller.value.position);
        }
      });

      if (widget.loop) {
        _controller.setLooping(true);
      }

      if (widget.autoPlay) {
        await _controller.play();
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const LoadingWidget(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Video display
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  if (widget.showControls) _buildControlsOverlay(),
                ],
              ),
            ),
          ),
          // Title
          if (widget.title != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return MouseRegion(
      onEnter: (_) => setState(() => _showControls = true),
      onExit: (_) => setState(() => _showControls = false),
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: AnimatedOpacity(
          opacity: _showControls || !_controller.value.isPlaying ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: Colors.black.withValues(alpha: 76),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 229),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: AppColors.onPrimary,
                      size: 32,
                    ),
                  ),
                ),
                // Progress bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor:
                              AppColors.primary.withValues(alpha: 76),
                          backgroundColor:
                              AppColors.onSurface.withValues(alpha: 76),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
      widget.onPause?.call();
    } else {
      await _controller.play();
      widget.onPlay?.call();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Compact Video Player - Minimal video player for lists
class CompactVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final double? progress;
  final VoidCallback? onTap;

  const CompactVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.progress,
    this.onTap,
  });

  @override
  State<CompactVideoPlayer> createState() => _CompactVideoPlayerState();
}

class _CompactVideoPlayerState extends State<CompactVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing compact video player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap ?? _togglePlayback,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Video thumbnail/play button
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: _isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 76),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppColors.onPrimary,
                            size: 32,
                          ),
                        ),
                      ],
                    )
                  : const LoadingWidget(),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.progress != null) ...[
                      const SizedBox(height: 8),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _controller.pause();
      } else {
        await _controller.play();
      }
    } catch (e) {
      debugPrint('Error toggling video playback: $e');
    }
  }
}
