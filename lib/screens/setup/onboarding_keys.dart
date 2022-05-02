import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/widgets/account_scaffold.dart';

class OnboardingKeys extends StatefulWidget {
  const OnboardingKeys() : super();

  @override
  State<OnboardingKeys> createState() => _OnboardingKeysState();
}

class _OnboardingKeysState extends State<OnboardingKeys> {
  AppController appController = AppController.shared;
  PodSetupModel model = PodSetupModel();
  final podUrlController = TextEditingController();
  String ownerKey = '';
  String dbKey = '';
  bool isCopied = false;
  bool _isKeysLoading = true;

  @override
  void initState() {
    _fetchKeys();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  AccountScaffold(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 112),
                  Text(
                    "Everything not saved will be lost.",
                    style: CVUFont.headline1,
                  ),
                  SizedBox(height: 30),
                  Text(
                    "These are your personal Crypto Keys. Save them in a safe place.",
                    style: CVUFont.bodyText1,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You will need them to log into your account.",
                    style: CVUFont.bodyText1,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "And we’re so secure that if you lose them, it’s lost forever (with your data!).",
                    style: CVUFont.bodyText1.copyWith(color: Color(0xffFE570F)),
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1),
                  if (appController.isDevelopersMode)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25),
                        Text("To use your keys locally in pymemri run:",
                            style: CVUFont.headline3),
                        SizedBox(height: 5),
                        Text(
                          "store_keys --owner_key ${ownerKey} --database_key ${dbKey}",
                          style: CVUFont.bodyText2,
                          softWrap: true,
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text:
                                    "store_keys --owner_key ${ownerKey} --database_key ${dbKey}"));
                          },
                          style: TextButton.styleFrom(backgroundColor: Color(0xffF0F0F0)),
                          child: Text(
                            "Copy",
                            style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
                          ),
                        ),
                        SizedBox(height: 25),
                        Divider(height: 1),
                      ],
                    ),
                  if (_isKeysLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              child: CircularProgressIndicator(),
                              width: 28,
                              height: 28,
                            ),
                            Text(
                              "Generating your keys",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "your login key".toUpperCase(),
                          style: CVUFont.smallCaps.copyWith(color: Color(0xff828282)),
                        ),
                        SizedBox(height: 3),
                        Text(
                          ownerKey,
                          style: CVUFont.bodyText2.copyWith(color: Color(0xff737373)),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "your password key".toUpperCase(),
                          style: CVUFont.smallCaps.copyWith(color: Color(0xff828282)),
                        ),
                        SizedBox(height: 3),
                        Text(
                          dbKey,
                          style: CVUFont.bodyText2.copyWith(color: Color(0xff737373)),
                        ),
                      ],
                    ),
                  SizedBox(height: 45),
                  Row(
                    children: [
                      if (!isCopied)
                        TextButton(
                          onPressed: () async {
                            Clipboard.setData(
                                ClipboardData(text: "Login: ${ownerKey}\nPassword: ${dbKey}"));
                            setState(() {
                              isCopied = true;
                            });
                          },
                          style: TextButton.styleFrom(backgroundColor: Color(0xffF0F0F0)),
                          child: Text(
                            "Copy keys",
                            style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
                          ),
                        ),
                      if (isCopied)
                        Flexible(
                          child: TextButton(
                            onPressed: () async {
                              appController.state = AppState.authenticated;
                            },
                            style: primaryButtonStyle,
                            child: Text("Keys saved"),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 45),
                ],
              ),
            ],
          ),
        );
  }

  Future<void> _fetchKeys() async {
    ownerKey = (await appController.podConnectionConfig)!.ownerKey;
    dbKey = (await appController.podConnectionConfig)!.databaseKey;

    if (mounted) {
      setState(() {
        _isKeysLoading = false;
      });
    }
  }
}
