import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/pod_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen() : super();

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late var _podProvider = Provider.of<PodProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  S.current.hi_there + "!",
                  style: CVUFont.headline1,
                ),
                SizedBox(height: 62),
                Text(
                  S.current.welcome_to_memri + "!",
                  style: CVUFont.bodyText1,
                ),
                SizedBox(height: 15),
                Text(
                  S.current.account_onboarding_message,
                  style: CVUFont.bodyText1,
                ),
                SizedBox(height: 45),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: () => _podProvider.signUp(context),
                      style: primaryButtonStyle,
                      child: Text(S.current.create_account),
                    ),
                    SizedBox(width: 30),
                    TextButton(
                      onPressed: () => _podProvider.openLoginScreen(context),
                      child: Text(
                        S.current.log_in,
                        style: CVUFont.buttonLabel
                            .copyWith(color: Color(0xff333333)),
                      ),
                      style: TextButton.styleFrom(backgroundColor: null),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 16),
                  child: _buildDeveloperButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperButton() {
    if (!app.settings.showDeveloperButton) {
      return Empty();
    }
    return InkWell(
      onTap: () => _podProvider.openLoginScreen(context, developerMode: true),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: S.current.switch_to + " ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: S.current.developers_mode,
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }
}
