import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/auth_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/components/error_message.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';
import 'package:provider/provider.dart';

class SaveKeysScreen extends StatelessWidget {
  const SaveKeysScreen() : super();

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      showSlider: false,
      child: Consumer<AuthProvider>(builder: (context, provider, child) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Text(
                  S.current.account_save_keys_title,
                  style: CVUFont.headline1,
                ),
                SizedBox(height: 32),
                Text(
                  S.current.account_save_keys_message,
                  style: CVUFont.bodyText1,
                ),
                SizedBox(height: 15),
                Text(
                  S.current.account_save_keys_message_highlight,
                  style: CVUFont.bodyText1.copyWith(color: Color(0xff4F56FE)),
                ),
                SizedBox(height: 16),
                Divider(height: 1),
                if (provider.developerMode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Text(S.current.account_save_keys_developer_hint,
                          style: CVUFont.headline3),
                      SizedBox(height: 5),
                      Text(
                        "store_keys --owner_key ${provider.ownerKey} --database_key ${provider.databaseKey}",
                        style: CVUFont.bodyText2,
                        softWrap: true,
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: provider.copyKeysToClipboard,
                        style: TextButton.styleFrom(
                            backgroundColor: Color(0xffF0F0F0)),
                        child: Text(
                          S.current.copy,
                          style: CVUFont.buttonLabel
                              .copyWith(color: Color(0xffFE570F)),
                        ),
                      ),
                      SizedBox(height: 25),
                      Divider(height: 1),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      S.current.your_login_key.toUpperCase(),
                      style:
                          CVUFont.smallCaps.copyWith(color: Color(0xff828282)),
                    ),
                    SizedBox(height: 5),
                    SelectableText(
                      provider.ownerKey,
                      style:
                          CVUFont.bodyText1.copyWith(color: Color(0xffE9500F)),
                    ),
                    SizedBox(height: 10),
                    Divider(height: 1),
                    SizedBox(height: 10),
                    Text(
                      S.current.your_password_key.toUpperCase(),
                      style:
                          CVUFont.smallCaps.copyWith(color: Color(0xff828282)),
                    ),
                    SizedBox(height: 5),
                    SelectableText(
                      provider.databaseKey,
                      style:
                          CVUFont.bodyText1.copyWith(color: Color(0xffE9500F)),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                if (provider.state != AuthState.error)
                  TextButton(
                    onPressed: provider.copyKeysToClipboard,
                    style: TextButton.styleFrom(
                        backgroundColor: Color(0xffFE570F)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          S.current.copy_keys_to_clipboard,
                          style:
                              CVUFont.buttonLabel.copyWith(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        app.icons.copyToClipboard(color: Colors.white),
                      ],
                    ),
                  ),
                if (provider.state == AuthState.error)
                  ErrorMessage(provider.errorMessage),
                if (provider.state == AuthState.savedKeys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        S.current.account_save_keys_copy_warning,
                        style: CVUFont.bodyText1,
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () => provider.finishAuthentication(context),
                        style: primaryButtonStyle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(S.current.account_save_keys_saved_button,
                              style: CVUFont.buttonLabel
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}
