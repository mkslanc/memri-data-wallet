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

  late dynamic? fileImageURL;
  late ImageProvider? bundleImage;
  late Color? color;
  //late CVUFont? font; TODO
  late String? iconName;

  init() async {
    fileImageURL = await getFileImageURL();
    if (fileImageURL == null) {
      bundleImage = await getBundleImage();
      if (bundleImage == null) {
        //font = await nodeResolver.propertyResolver.font();
        color = await nodeResolver.propertyResolver.color();
        iconName = await nodeResolver.propertyResolver.string("systemName");
      }
    }
  }

  getFileImageURL() async /*: URL?*/ {
    var imageURI = await nodeResolver.propertyResolver.fileUID("image");
    if (imageURI == null) {
      return null;
    } //TODO:
    //return FileStorageController.getURLForFile(withUUID: imageURI);
  }

  Future<ImageProvider?> getBundleImage() async /*: UIImage?*/ {
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
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (fileImageURL != null) {
              return Text("place for your image");
              /*TODO: MemriImageView(imageURL: imageURL, fitContent: nodeResolver.propertyResolver.sizingMode() == .fit)
          .if(nodeResolver.propertyResolver.sizingMode() == .fit) {
      $0.aspectRatio(
      MemriImageView.getAspectRatio(of: imageURL) ?? 1,
      contentMode: .fit
      )
      }*/
            } else if (bundleImage != null) {
              return Image(image: bundleImage!);
            } else if (iconName != null) {
              return Icon(
                MemriIcon.getByName(iconName!),
                color: color,
                //size: font?.size,
              );
              //TODO: .renderingMode(.template).if(nodeResolver.propertyResolver.bool("resizable", defaultValue: false)) { $0.resizable() }
              //.if(nodeResolver.propertyResolver.sizingMode() == .fit) { $0.aspectRatio(contentMode: .fit) }
            } else {
              return Icon(
                Icons.error,
                color: Color(0x993c3c43),
              );
            }
          }
          return Text("");
        });
  }
}
