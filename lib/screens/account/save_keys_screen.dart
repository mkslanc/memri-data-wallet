import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/providers/pod_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';
import 'package:provider/provider.dart';

class SaveKeysScreen extends StatefulWidget {
  const SaveKeysScreen() : super();

  @override
  State<SaveKeysScreen> createState() => _SaveKeysScreenState();
}

class _SaveKeysScreenState extends State<SaveKeysScreen> {
  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      showSlider: false,
      child: Consumer<PodProvider>(builder: (context, provider, child) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Text(
                  "Save your crypto keys",
                  style: CVUFont.headline1,
                ),
                SizedBox(height: 32),
                Text(
                  "These are your personal Crypto Keys. Save them in a safe place.",
                  style: CVUFont.bodyText1,
                ),
                SizedBox(height: 15),
                Text(
                  "You will need your keys to log into your account. If you lose your keys, you will not be able to recover them and you will permanently lose access to your account and POD. ",
                  style: CVUFont.bodyText1.copyWith(color: Color(0xff4F56FE)),
                ),
                SizedBox(height: 16),
                Divider(height: 1),
                if (provider.developerMode)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Text("To use your keys locally in pymemri run:",
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
                          "Copy",
                          style: CVUFont.buttonLabel
                              .copyWith(color: Color(0xffFE570F)),
                        ),
                      ),
                      SizedBox(height: 25),
                      Divider(height: 1),
                    ],
                  ),
                // if (_isKeysLoading)
                //   Padding(
                //     padding: EdgeInsets.only(top: 24),
                //     child: Center(
                //       child: Column(
                //         children: [
                //           SizedBox(
                //             child: CircularProgressIndicator(),
                //             width: 28,
                //             height: 28,
                //           ),
                //           Text(
                //             "Generating your keys",
                //             style: TextStyle(color: Colors.black),
                //           ),
                //         ],
                //       ),
                //     ),
                //   )
                // else if (!_hasAuthError)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "your login key".toUpperCase(),
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
                      "your password key".toUpperCase(),
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
                // if (!_hasAuthError)
                TextButton(
                  onPressed: provider.copyKeysToClipboard,
                  style:
                      TextButton.styleFrom(backgroundColor: Color(0xffFE570F)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Copy keys to clipboard",
                        style:
                            CVUFont.buttonLabel.copyWith(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      app.icons.copyToClipboard(color: Colors.white),
                    ],
                  ),
                ),
                // if (_hasAuthError) ErrorMessage(appController.model.errorString!),
                if (provider.state == AuthState.savedKeys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "You need your login and password keys in the creating app process.",
                        style: CVUFont.bodyText1,
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () => provider.finishAuthentication(context),
                        style: primaryButtonStyle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("I’ve saved the keys",
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
