import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/pod_provider.dart';
import 'package:memri/widgets/components/error_message.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';
import 'package:memri/widgets/simple_text_editor.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen() : super();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ownerKeyController = TextEditingController();
  final _databaseKeyController = TextEditingController();

  @override
  void dispose() {
    _ownerKeyController.dispose();
    _databaseKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      child: Consumer<PodProvider>(
          builder: (context, provider, child) => Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          S.current.account_login_title,
                          style: CVUFont.headline1,
                        ),
                        SizedBox(height: 62),
                        Text(
                          S.current.account_login_message,
                          style: CVUFont.bodyText1,
                        ),
                        SizedBox(height: 20),
                        SimpleTextEditor(
                          controller: _ownerKeyController,
                          title: S.current.your_login_key.toUpperCase(),
                        ),
                        SizedBox(height: 20),
                        SimpleTextEditor(
                          controller: _databaseKeyController,
                          title: S.current.your_password_key.toUpperCase(),
                        ),
                        SizedBox(height: 20),
                        if (provider.state == AuthState.error)
                          ErrorMessage(provider.errorMessage),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () => provider.login(
                            context: context,
                            ownerKey: _ownerKeyController.text,
                            dbKey: _databaseKeyController.text,
                          ),
                          style: primaryButtonStyle,
                          child: Text(S.current.log_in),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.only(top: 60, bottom: 16),
                          child: _buildNewAccountButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
    );
  }

  Widget _buildNewAccountButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  S.current.account_login_create_account_button_question + " ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: S.current.account_login_create_account_button_answer,
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }
}
