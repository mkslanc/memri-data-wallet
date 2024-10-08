import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/utilities/factory_reset.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/space.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdditionalNavigationView extends StatefulWidget {
  AdditionalNavigationView();

  @override
  _AdditionalNavigationViewState createState() =>
      _AdditionalNavigationViewState();
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
                  Row(
                    children: [
                      app.icons.key(),
                      Text(
                        "Your pod keys",
                        style:
                            CVUFont.bodyText1.copyWith(color: Colors.white),
                      )
                    ],
                  ),
                  InkWell(
                      onTap: () => factoryReset(context),
                      child: Row(
                        children: [
                          app.icons.logOut(),
                          Text(
                            "Sign out and reset",
                            style:
                                CVUFont.bodyText1.copyWith(color: Colors.white),
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
                      onTap: () {
                        // MixpanelAnalyticsService().logDiscordButton();
                        launchUrlString(
                            "https://discord.com/invite/BcRfajJk4k");
                      },
                      child: Text(
                        "Discord",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launchUrlString(
                          "https://docs.memri.io/guides/import_your_data/"),
                      child: Text(
                        "Guides",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launchUrlString("https://docs.memri.io/"),
                      child: Text(
                        "Documentation",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () {
                        // MixpanelAnalyticsService().logGitlabButton();
                        launchUrlString(
                            "https://gitlab.memri.io/users/sign_in");
                      },
                      child: Text(
                        "Repositories",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () {
                        // MixpanelAnalyticsService().logDiscordButton();
                        launchUrlString(
                            "https://discord.com/invite/BcRfajJk4k");
                      },
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
                      onTap: () => launchUrlString("https://memri.io/privacy/"),
                      child: Text(
                        "Privacy Policy",
                        style: CVUFont.bodyText1.copyWith(color: Colors.white),
                      )),
                  InkWell(
                      onTap: () => launchUrlString("https://memri.io/contact/"),
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
