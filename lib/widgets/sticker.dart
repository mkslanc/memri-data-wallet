import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/utilities/helpers/responsive_helper.dart';

class Sticker extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? description;
  final List<String>? buttonsTitle;
  final List<VoidCallback>? buttonsCallback;

  const Sticker({
    Key? key,
    required this.title,
    this.icon,
    this.description,
    this.buttonsTitle,
    this.buttonsCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper(context).isSmallScreen
        ? AspectRatio(
            aspectRatio: 4 / 4.5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: _buildBody(),
            ),
          )
        : Container(
            width: 350,
            height: 450,
            child: _buildBody(),
          );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) icon!,
            if (icon != null) SizedBox(height: 50),
            Text(title, style: CVUFont.headline2),
            if (description != null) SizedBox(height: 20),
            if (description != null)
              Text(
                description!,
                style:
                    CVUFont.bodyText1.copyWith(color: app.colors.brandGreyText),
              ),
            SizedBox(height: 40),
            if (buttonsTitle != null)
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<Widget>.generate(
                    buttonsTitle!.length,
                    (index) => Column(
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(0))),
                          onPressed: buttonsCallback![index],
                          child: Row(
                            children: [
                              Text(
                                buttonsTitle![index],
                                style: CVUFont.bodyText1
                                    .copyWith(color: app.colors.primary),
                              ),
                              SizedBox(width: 10),
                              app.icons.arrowRight(color: app.colors.primary),
                            ],
                          ),
                        ),
                        if (index < buttonsTitle!.length - 1)
                          SizedBox(height: 40),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
