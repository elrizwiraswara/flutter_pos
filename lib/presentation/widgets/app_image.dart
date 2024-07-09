import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../app/assets/app_assets.dart';
import '../../app/themes/app_sizes.dart';
import 'app_progress_indicator.dart';

// App Image Widget
// v.2.0.8
// by Elriz Wiraswara

enum ImgProvider {
  networkImage,
  assetImage,
  fileImage,
  svgImageAsset,
  svgImageFile,
  svgImageNetwork,
}

// For development purpose
const String randomImage = 'https://picsum.photos/500';

class AppImage extends StatefulWidget {
  final String image;
  final String placeholder;
  final List<String>? allImages;
  final ImgProvider imgProvider;
  final BoxFit fit;
  final Duration fadeInDuration;
  final Widget? errorWidget;
  final Widget? placeHolderWidget;
  final bool enableFullScreenView;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;

  const AppImage({
    super.key,
    required this.image,
    this.placeholder = AppAssets.loading,
    this.allImages,
    this.imgProvider = ImgProvider.networkImage,
    this.fit = BoxFit.cover,
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.errorWidget,
    this.placeHolderWidget,
    this.enableFullScreenView = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  void onTapImage() {
    if ((widget.allImages == null || widget.allImages!.isEmpty) && widget.image == '') {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppImageViewer(
          index: (widget.allImages?.isNotEmpty ?? false) ? widget.allImages!.indexOf(widget.image) : 0,
          images: widget.allImages ?? [widget.image],
          imgProvider: widget.imgProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enableFullScreenView ? onTapImage : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius == null ? null : BorderRadius.circular(widget.borderRadius!),
          border: widget.borderWidth == null
              ? null
              : Border.all(
                  width: widget.borderWidth!,
                  color: widget.borderColor ?? Theme.of(context).colorScheme.outline,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((widget.borderRadius ?? 0) - (widget.borderWidth ?? 0)),
          child: widget.image.isNotEmpty ? child() : errorWidget(),
        ),
      ),
    );
  }

  Widget child() {
    if (widget.imgProvider == ImgProvider.assetImage) {
      return assetImage();
    }

    if (widget.imgProvider == ImgProvider.fileImage) {
      return fileImage();
    }

    if (widget.imgProvider == ImgProvider.svgImageAsset) {
      return svgImageAsset();
    }

    if (widget.imgProvider == ImgProvider.svgImageFile) {
      return svgImageFile();
    }

    if (widget.imgProvider == ImgProvider.svgImageNetwork) {
      return svgImageNetwork();
    }

    return networkImage();
  }

  Widget networkImage() {
    return CachedNetworkImage(
      imageUrl: widget.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: widget.fadeInDuration,
      placeholder: (context, string) {
        return placeHolderWidget();
      },
      errorWidget: (context, object, stack) {
        return errorWidget();
      },
    );
  }

  Widget assetImage() {
    return FadeInImage(
      width: widget.width,
      height: widget.height,
      fadeInDuration: widget.fadeInDuration,
      fit: widget.fit,
      placeholder: placeHolderImage(),
      image: AssetImage(widget.image),
      imageErrorBuilder: (context, object, stack) {
        return errorWidget();
      },
    );
  }

  Widget fileImage() {
    return FadeInImage(
      width: widget.width,
      height: widget.height,
      fadeInDuration: widget.fadeInDuration,
      fit: widget.fit,
      placeholder: placeHolderImage(),
      image: FileImage(File(widget.image)),
      imageErrorBuilder: (context, object, stack) {
        return errorWidget();
      },
    );
  }

  Widget svgImageAsset() {
    return SvgPicture.asset(
      widget.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholderBuilder: (_) {
        return placeHolderWidget();
      },
    );
  }

  Widget svgImageFile() {
    return SvgPicture.file(
      File(widget.image),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholderBuilder: (_) {
        return placeHolderWidget();
      },
    );
  }

  Widget svgImageNetwork() {
    return SvgPicture.network(
      widget.image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholderBuilder: (_) {
        return placeHolderWidget();
      },
    );
  }

  AssetImage placeHolderImage() {
    return AssetImage(widget.placeholder);
  }

  Widget placeHolderWidget() {
    return Image.asset(widget.placeholder);
  }

  Widget errorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Center(
      child: Icon(
        Icons.broken_image_rounded,
        size: (widget.width ?? widget.height ?? AppSizes.padding * 2) / 2,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

// Full screen images viewer
class AppImageViewer extends StatefulWidget {
  final int index;
  final List<String> images;
  final ImgProvider imgProvider;

  const AppImageViewer({
    super.key,
    this.index = 0,
    required this.images,
    this.imgProvider = ImgProvider.networkImage,
  });

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  final _pageController = PageController();

  ImageProvider imageProvider(String image) {
    if (widget.imgProvider == ImgProvider.fileImage) {
      return FileImage(File(image));
    }

    if (widget.imgProvider == ImgProvider.assetImage) {
      return AssetImage(
        image,
      );
    }

    return NetworkImage(image);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(widget.index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: imageProvider(widget.images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained,
            heroAttributes: const PhotoViewHeroAttributes(tag: 'image_viewer'),
          );
        },
        itemCount: widget.images.length,
        loadingBuilder: (context, event) {
          return const AppProgressIndicator();
        },
      ),
    );
  }
}
