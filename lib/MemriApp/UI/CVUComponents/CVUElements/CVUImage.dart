import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/FileStorageController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVU_Other.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// A CVU element for displaying an image
/// - Use the `image` property to display an Image item
/// - Use the `bundleImage` property to display an icon pre-packaged with the Memri App
/// - Use the `systemName` property to display an iOS SFSymbols (system) icon
// ignore: must_be_immutable
class CVUImage extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUImage({required this.nodeResolver});

  @override
  _CVUImageState createState() => _CVUImageState();
}

class _CVUImageState extends State<CVUImage> {
  String? fileImageURL;

  ImageProvider? bundleImage;

  Color? color;

  CVUFont? font;

  String? iconName;

  late CVU_SizingMode sizingMode;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  void didUpdateWidget(covariant CVUImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    fileImageURL = await getFileImageURL();
    sizingMode = await widget.nodeResolver.propertyResolver.sizingMode();
    if (fileImageURL == null) {
      bundleImage = await getBundleImage();
      if (bundleImage == null) {
        font = await widget.nodeResolver.propertyResolver.font();
        color = await widget.nodeResolver.propertyResolver.color();
        iconName = await widget.nodeResolver.propertyResolver.string("systemName");
      }
    }
  }

  Future<String?> getFileImageURL() async {
    var imageURI = await widget.nodeResolver.propertyResolver.fileUID("image");
    if (imageURI == null) {
      return null;
    }
    return FileStorageController.getURLForFile(imageURI);
  }

  Future<ImageProvider?> getBundleImage() async {
    var imageName = await widget.nodeResolver.propertyResolver.string("bundleImage");
    if (imageName == null) {
      return null;
    }
    var image = AssetImage(imageName);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (fileImageURL != null) {
            return Image(
                image: ResizeImage(AssetImage(fileImageURL!),
                    width: MediaQuery.of(context).size.width.toInt()), //TODO: to avoid lagging
                fit: sizingMode == CVU_SizingMode.fill ? BoxFit.fill : BoxFit.fitWidth,
            );
          } else if (bundleImage != null) {
            return Image(image: bundleImage!);
          } else if (iconName != null) {
            return Center(
              child: Icon(
                MemriIcon.getByName(iconName!),
                color: color,
                size: font?.size,
              ),
            );
            //TODO: .renderingMode(.template).if(nodeResolver.propertyResolver.bool("resizable", defaultValue: false)) { $0.resizable() }
            //.if(nodeResolver.propertyResolver.sizingMode() == .fit) { $0.aspectRatio(contentMode: .fit) }
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Icon(
                Icons.error,
                color: Color(0x993c3c43),
              ),
            );
          } else {
            return Empty();
          }
        });
  }
}
