import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/lesson_content.dart';

/// A unified media player widget that handles both audio and video content
class MediaPlayerWidget extends StatefulWidget {
  final LessonContent content;
  final VoidCallback? onComplete;

  const MediaPlayerWidget({
    super.key,
    required this.content,
    this.onComplete,
  });

  @override
  State<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.content.type == ContentType.audio) {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setSourceUrl(widget.content.content);

        _audioPlayer!.onDurationChanged.listen((duration) {
          setState(() {
            _duration = duration;
          });
        });

        _audioPlayer!.onPositionChanged.listen((position) {
          setState(() {
            _position = position;
          });
        });

        _audioPlayer!.onPlayerComplete.listen((_) {
          setState(() {
            _isPlaying = false;
          });
          widget.onComplete?.call();
        });
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.content.content),
        );
        await _videoController!.initialize();

        _videoController!.addListener(() {
          setState(() {
            _duration = _videoController!.value.duration;
            _position = _videoController!.value.position;
            _isPlaying = _videoController!.value.isPlaying;
          });
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _togglePlayback() {
    if (widget.content.type == ContentType.audio) {
      if (_isPlaying) {
        _audioPlayer?.pause();
      } else {
        _audioPlayer?.resume();
      }
    } else {
      if (_isPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seekTo(Duration position) {
    if (widget.content.type == ContentType.audio) {
      _audioPlayer?.seek(position);
    } else {
      _videoController?.seekTo(position);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading media',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeMedia,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Column(
        children: [
          // Video player (if video content)
          if (widget.content.type == ContentType.video &&
              _videoController != null)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Media Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress bar
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _seekTo(Duration(seconds: value.toInt()));
                  },
                ),

                // Time and controls
                Row(
                  children: [
                    // Play/Pause button
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),

                    // Time display
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: const TextStyle(fontSize: 12),
                    ),

                    const Spacer(),

                    // Media type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.content.type == ContentType.audio
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.content.type == ContentType.audio
                                ? Icons.audiotrack
                                : Icons.videocam,
                            size: 14,
                            color: widget.content.type == ContentType.audio
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.content.type == ContentType.audio
                                ? 'Audio'
                                : 'Video',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.content.type == ContentType.audio
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
