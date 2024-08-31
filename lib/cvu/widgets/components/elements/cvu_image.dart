import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/cvu/models/cvu_sizing_mode.dart';
import 'package:memri/utilities/extensions/icon_data.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

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
  ImageProvider? fileImage;
  ImageProvider? bundleImage;
  Color? color;
  CVUFont? font;
  String? iconName;
  String? vectorImageName;

  late CVU_SizingMode sizingMode;
  late Future _init;

  bool isLoaded = false;
  bool isVector = false;
  double? maxWidth;

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
    isVector =
        (widget.nodeResolver.propertyResolver.boolean("isVector", false))!;
    maxWidth = widget.nodeResolver.propertyResolver.maxWidth;
    if (isVector) {
      vectorImageName =
          widget.nodeResolver.propertyResolver.string("bundleImage");
      color = widget.nodeResolver.propertyResolver.color();
    } else {
      fileImage = await getFileImage();
      sizingMode = widget.nodeResolver.propertyResolver.sizingMode();
      if (fileImage == null) {
        bundleImage = await getBundleImage();
        if (bundleImage == null) {
          font = widget.nodeResolver.propertyResolver.font();
          color = widget.nodeResolver.propertyResolver.color();
          iconName = widget.nodeResolver.propertyResolver.string("systemName");
        }
      }
    }
    isLoaded = true;
  }

  Future<ImageProvider?> getFileImage() async {
    var imageURI = widget.nodeResolver.propertyResolver.fileUID("image");
    if (imageURI == null) {
      imageURI = widget.nodeResolver.propertyResolver.string("image");
      if (imageURI != null) {
        return await FileStorageController.getImage(fileURL: imageURI);
      }
      return null;
    }
    return await FileStorageController.getImage(uuid: imageURI);
  }

  Future<ImageProvider?> getBundleImage() async {
    var imageName = widget.nodeResolver.propertyResolver.string("bundleImage");
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
          if (fileImage != null) {
            return Image(
              image: ResizeImage(fileImage!,
                  width: maxWidth != null
                      ? maxWidth!.toInt()
                      : MediaQuery.of(context)
                          .size
                          .width
                          .toInt()), //TODO: to avoid lagging
              fit: sizingMode == CVU_SizingMode.fill
                  ? BoxFit.fill
                  : BoxFit.fitWidth,
            );
          } else if (isVector) {
            return SvgPicture.asset(
              "assets/images/" + vectorImageName! + ".svg",
              color: color,
            );
          } else if (bundleImage != null) {
            return Image(image: bundleImage!);
          } else if (iconName != null) {
            return Icon(
              MemriIcon.getByName(iconName!),
              color: color,
              size: font?.size,
            );
            //TODO: .renderingMode(.template).if(nodeResolver.propertyResolver.bool("resizable", defaultValue: false)) { $0.resizable() }
            //.if(nodeResolver.propertyResolver.sizingMode() == .fit) { $0.aspectRatio(contentMode: .fit) }
          } else if (isLoaded) {
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
