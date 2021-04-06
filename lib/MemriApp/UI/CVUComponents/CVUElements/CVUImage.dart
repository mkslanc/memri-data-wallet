import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';

/// A CVU element for displaying an image
/// - Use the `image` property to display an Image item
/// - Use the `bundleImage` property to display an icon pre-packaged with the Memri App
/// - Use the `systemName` property to display an iOS SFSymbols (system) icon
class CVUImage extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUImage({required this.nodeResolver});

  get fileImageURL async /*: URL?*/ {
    var imageURI = await nodeResolver.propertyResolver.fileUID("image");
    if (imageURI == null) {
      return;
    } //TODO:
    //return FileStorageController.getURLForFile(withUUID: imageURI);
  }

  Future<ImageProvider?> get bundleImage async /*: UIImage?*/ {
    var imageName = await nodeResolver.propertyResolver.string("bundleImage");
    if (imageName == null) {
      return null;
    }
    var image = AssetImage(imageName);
    /* TODO: need some way to check
        if (image == null) {
            return;
        }*/
    return image;
  }

  @override
  Widget build(BuildContext context) {
    var imageURL = fileImageURL;
    if (imageURL != null) {
      return Text("place for your image");
      /*TODO: MemriImageView(imageURL: imageURL, fitContent: nodeResolver.propertyResolver.sizingMode() == .fit)
          .if(nodeResolver.propertyResolver.sizingMode() == .fit) {
      $0.aspectRatio(
      MemriImageView.getAspectRatio(of: imageURL) ?? 1,
      contentMode: .fit
      )
      }*/
    } else {
      return FutureBuilder(
          future: bundleImage,
          builder: (BuildContext builder, AsyncSnapshot<ImageProvider?> snapshot) {
            if (snapshot.hasData) {
              return Image(image: (snapshot.data)!);
            } else {
              return FutureBuilder(
                  future: nodeResolver.propertyResolver.string("systemName"),
                  builder: (BuildContext builder, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.hasData) {
                      var iconName = snapshot.data;
                      return Icon(MemriIcon.getByName(iconName!));
                      //TODO: .renderingMode(.template).if(nodeResolver.propertyResolver.bool("resizable", defaultValue: false)) { $0.resizable() }
                      //.if(nodeResolver.propertyResolver.sizingMode() == .fit) { $0.aspectRatio(contentMode: .fit) }
                    } else {
                      return Icon(
                        Icons.error,
                        color: Color(0x993c3c43),
                      );
                    }
                  });
            }
          });
    }
  }
}
