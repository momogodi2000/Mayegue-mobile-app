import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// Image Viewer Widget - Reusable image display component with zoom and pan
class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableZoom;
  final bool enablePan;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableZoom = false,
    this.enablePan = false,
    this.onTap,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _hasError
        ? (widget.errorWidget ??
            Container(
              color: AppColors.error.withValues(alpha: 25),
              child: const Icon(
                Icons.broken_image,
                color: AppColors.error,
                size: 48,
              ),
            ))
        : Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return widget.placeholder ??
                  Container(
                    color: AppColors.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  );
            },
            errorBuilder: (context, error, stackTrace) {
              setState(() {
                _hasError = true;
              });
              return widget.errorWidget ??
                  Container(
                    color: AppColors.error.withValues(alpha: 25),
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.error,
                      size: 48,
                    ),
                  );
            },
          );

    if (widget.enableZoom || widget.enablePan) {
      return GestureDetector(
        onTap: widget.onTap,
        child: InteractiveViewer(
          panEnabled: widget.enablePan,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: imageWidget,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: imageWidget,
    );
  }
}

/// Image Gallery - Grid view of images
class ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final Function(String)? onImageTap;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onImageTap?.call(imageUrls[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageViewer(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

/// Full Screen Image Viewer - Modal full screen image display
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: title != null ? Text(title!) : null,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: ImageViewer(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// Show full screen image viewer
void showFullScreenImage(BuildContext context, String imageUrl, {String? title}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FullScreenImageViewer(
        imageUrl: imageUrl,
        title: title,
      ),
    ),
  );
}