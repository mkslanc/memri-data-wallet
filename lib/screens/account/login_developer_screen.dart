import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/auth_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/components/error_message.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';
import 'package:memri/widgets/simple_text_editor.dart';
import 'package:provider/provider.dart';

class LoginDeveloperScreen extends StatefulWidget {
  LoginDeveloperScreen();

  @override
  State<LoginDeveloperScreen> createState() => _LoginDeveloperScreenState();
}

class _LoginDeveloperScreenState extends State<LoginDeveloperScreen> {
  final _podUrlController = TextEditingController();
  final _ownerKeyController = TextEditingController();
  final _databaseKeyController = TextEditingController();

  @override
  void initState() {
    _podUrlController.text = app.settings.defaultDevPodUrl;
    super.initState();
  }

  @override
  void dispose() {
    _podUrlController.dispose();
    _ownerKeyController.dispose();
    _databaseKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      child: Consumer<AuthProvider>(
          builder: (context, provider, _) => Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          S.current.account_login_dev_title,
                          style: CVUFont.headline1,
                        ),
                        SizedBox(height: 62),
                        Text(
                          S.current.account_login_dev_message,
                          style: CVUFont.bodyText1,
                        ),
                        SizedBox(height: 15),
                        Text(
                          S.current.account_login_dev_description,
                          style: CVUFont.bodyText1,
                        ),
                        SizedBox(height: 20),
                        SimpleTextEditor(
                          controller: _podUrlController,
                          title: S.current.your_pod_address.toUpperCase(),
                          hintText: app.settings.defaultPodUrl,
                        ),
                        if (provider.devState == DeveloperAuthState.devSignIn)
                          Column(
                            children: [
                              SizedBox(height: 20),
                              SimpleTextEditor(
                                controller: _ownerKeyController,
                                title: S.current.your_login_key.toUpperCase(),
                              ),
                              SizedBox(height: 20),
                              SimpleTextEditor(
                                controller: _databaseKeyController,
                                title:
                                    S.current.your_password_key.toUpperCase(),
                              ),
                            ],
                          ),
                        Row(children: [
                            Checkbox(
                                value: provider.importDemoData,
                                onChanged: (value) {
                                  provider.importDemoData = value!;
                                }),
                            Text(
                            "Import demo data",
                            style: CVUFont.bodyText1,
                          ),
                        ],),
                        SizedBox(height: 45),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 25,
                          children: [
                            TextButton(
                              onPressed: () => provider.devState ==
                                      DeveloperAuthState.devSignUp
                                  ? provider.signUp(
                                      context,
                                      podAddress: _podUrlController.text,
                                    )
                                  : provider.login(
                                      context: context,
                                      ownerKey: _ownerKeyController.text,
                                      dbKey: _databaseKeyController.text,
                                      podAddress: _podUrlController.text,
                                    ),
                              style: primaryButtonStyle,
                              child: Text(provider.devState ==
                                      DeveloperAuthState.devSignUp
                                  ? S.current.create_new_account
                                  : S.current.log_into_your_pod),
                            ),
                            SizedBox(width: 30),
                            InkWell(
                              onTap: () => provider.devState ==
                                      DeveloperAuthState.devSignUp
                                  ? provider.updateDevStateToSignIn()
                                  : provider.updateDevStateToSignUp(),
                              child: Text(
                                provider.devState ==
                                        DeveloperAuthState.devSignUp
                                    ? S.current.log_into_your_pod
                                    : S.current.create_new_account,
                                style: CVUFont.buttonLabel
                                    .copyWith(color: Color(0xff333333)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        if (provider.state == AuthState.error)
                          ErrorMessage(provider.errorMessage),
                        /*Padding(
                          padding: EdgeInsets.only(top: 60, bottom: 16),
                          child: _buildSwitchModeButton(),
                        ),*/
                      ],
                    ),
                  ),
                ),
              )),
    );
  }

  Widget _buildSwitchModeButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Switch to ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: "standard mode",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }
}
