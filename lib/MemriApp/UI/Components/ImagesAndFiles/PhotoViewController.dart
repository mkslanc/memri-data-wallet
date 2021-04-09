import 'package:flutter/material.dart';

class PhotoViewerView extends StatelessWidget {
  final Future<PhotoViewerControllerPhotoItem?> Function(int index) photoItemProvider;
  final int initialIndex;

  PhotoViewerView({required this.photoItemProvider, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: photoItemProvider(initialIndex),
        builder: (BuildContext context, AsyncSnapshot<PhotoViewerControllerPhotoItem?> snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.done) {
            var photoItem = snapshot.data;
            print(photoItem);

            if (photoItem == null) {
              return SizedBox.shrink();
            }

            return Expanded(
              child: Stack(
                children: [
                  Image(
                    image: AssetImage(photoItem.imageURL),
                  ),
                  photoItem.overlay
                ],
              ),
            );
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
}

class PhotoViewerControllerPhotoItem {
  final int index;
  final String imageURL;
  final Widget overlay;

  PhotoViewerControllerPhotoItem(this.index, this.imageURL, this.overlay);
}
