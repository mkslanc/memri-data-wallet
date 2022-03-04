import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/utils/factory_reset.dart';
import 'package:memri/widgets/space.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalNavigationView extends StatefulWidget {
  final SceneController sceneController;

  AdditionalNavigationView({required this.sceneController});

  @override
  _AdditionalNavigationViewState createState() => _AdditionalNavigationViewState();
}

class _AdditionalNavigationViewState extends State<AdditionalNavigationView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: space(
                15,
                [
                  Text(
                    "Account",
                    style: CVUFont.bodyBold.copyWith(color: Colors.white),
                  ),
                  InkWell(
                      onTap: () {
                        widget.sceneController.navigateToNewContext(
                            clearStack: true, animated: false, viewName: "allCryptoKeys");
                        widget.sceneController.navigationIsVisible.value = false;
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/images/ico_key.svg"),
                          Text(
                            "Your pod keys",
                            style: CVUFont.bodyText1.copyWith(color: Colors.white),
                          )
                        ],
                      )),
                  InkWell(
                      onTap: () => factoryReset(context),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/images/ico_log_out.svg"),
                          Text(
                            "Sign out and reset",
                            style: CVUFont.bodyText1.copyWith(color: Colors.white),
                          )
                        ],
                      ))
                ],
                Axis.vertical)),
        SizedBox(
          width: 200,
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: space(
                10,
                [
                  Text(
                    "Community & Support",
                    style: CVUFont.bodyBold.copyWith(color: Colors.white),
                  ),
                  InkWell(
                      onTap: () => launch("https://discord.com/invite/BcRfajJk4k"),
                      child: Text(
                        "Discord",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("https://blog.memri.io/"),
                      child: Text(
                        "Tutorials",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("http://memri.docs.memri.io/pymemri/"),
                      child: Text(
                        "Documentation",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("https://gitlab.memri.io/memri"),
                      child: Text(
                        "Repositories",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () {},
                      child: Text(
                        "Get support",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                ],
                Axis.vertical)),
        SizedBox(
          width: 200,
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: space(
                10,
                [
                  Text(
                    "Legal",
                    style: CVUFont.bodyBold.copyWith(color: Colors.white),
                  ),
                  InkWell(
                      onTap: () => launch("https://memri.io/privacy/"),
                      child: Text(
                        "Privacy and  Security",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("https://discord.com/invite/BcRfajJk4k"),
                      child: Text(
                        "Report a bug",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("https://discord.com/invite/BcRfajJk4k"),
                      child: Text(
                        "Request a feature",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launch("https://discord.com/invite/BcRfajJk4k"),
                      child: Text(
                        "Contact us",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                ],
                Axis.vertical))
      ],
    );
  }
}
