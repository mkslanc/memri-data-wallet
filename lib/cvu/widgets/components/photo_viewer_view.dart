import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/widgets/empty.dart';

class PhotoViewerView extends StatefulWidget {
  final void Function(bool) onToggleOverlayVisibility;
  final Future<PhotoViewerControllerPhotoItem?> Function(int index) photoItemProvider;
  final int initialIndex;
  final ViewContextController viewContext;

  PhotoViewerView(
      {required this.onToggleOverlayVisibility,
      required this.viewContext,
      required this.photoItemProvider,
      required this.initialIndex});

  @override
  _PhotoViewerViewState createState() => _PhotoViewerViewState(initialIndex);
}

class _PhotoViewerViewState extends State<PhotoViewerView> {
  int _initialIndex;
  late PageController _pageController;

  _PhotoViewerViewState(this._initialIndex);

  late final Future<List<PhotoViewerControllerPhotoItem?>> _resolveImages;

  @override
  initState() {
    super.initState();
    _resolveImages = resolveImages();
  }

  Future<List<PhotoViewerControllerPhotoItem?>> resolveImages() async {
    return await Future.wait(widget.viewContext.items.mapIndexed((index, item) async {
      return await widget.photoItemProvider(index);
    }));
  }

  @override
  Widget build(BuildContext context) {
    _pageController = PageController(initialPage: _initialIndex);
    return FutureBuilder(
        future: _resolveImages,
        builder:
            (BuildContext context, AsyncSnapshot<List<PhotoViewerControllerPhotoItem?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var photoItems = snapshot.data;

            if (photoItems == null || photoItems.length == 0) {
              return Empty();
            }
            return PageView(controller: _pageController, children: getImages(photoItems));
          } else {
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            );
          }
        });
  }

  List<Widget> getImages(List<PhotoViewerControllerPhotoItem?> photoItems) {
    return photoItems
        .map((photoItem) => photoItem == null
            ? Center(
                child: Icon(
                Icons.error,
                color: Color(0x993c3c43),
              ))
            : PhotoScalingView(photoItem: photoItem))
        .toList();
  }
//TODO: overlay changing with animations
}

class PhotoViewerControllerPhotoItem {
  final int index;
  final ImageProvider imageProvider;
  final Widget overlay;

  PhotoViewerControllerPhotoItem(this.index, this.imageProvider, this.overlay);
}

class PhotoScalingView extends StatefulWidget {
  final PhotoViewerControllerPhotoItem photoItem;

  PhotoScalingView({required this.photoItem});

  @override
  _PhotoScalingViewState createState() => _PhotoScalingViewState();
}

class _PhotoScalingViewState extends State<PhotoScalingView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<Matrix4> _animation;

  final _transformationController = TransformationController();

  late TapDownDetails _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        child: Image(
          image: widget.photoItem.imageProvider,
        ),
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    Matrix4 _endMatrix;
    Offset _position = _doubleTapDetails.localPosition;

    if (_transformationController.value != Matrix4.identity()) {
      _endMatrix = Matrix4.identity();
    } else {
      _endMatrix = Matrix4.identity()
        ..translate(-_position.dx * 2, -_position.dy * 2)
        ..scale(3.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: _endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }
}
