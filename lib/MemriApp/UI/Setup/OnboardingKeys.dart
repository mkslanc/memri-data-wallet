import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/Controllers/API/AuthKey.dart';
import 'package:memri/MemriApp/Controllers/API/Authentication_shared.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/Components/Button/PrimaryButton.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'SetupScreenModel.dart';

class OnboardingKeys extends StatefulWidget {
  const OnboardingKeys() : super();

  @override
  State<OnboardingKeys> createState() => _OnboardingKeysState();
}

class _OnboardingKeysState extends State<OnboardingKeys> {
  AppController appController = AppController.shared;
  SetupScreenModel model = SetupScreenModel();
  final podUrlController = TextEditingController();
  String? ownerKey;
  String? dbKey;
  bool isCopied = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => MaterialApp(
            color: Color(0xffE5E5E5),
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
                      child: Container(
                        width: geom.maxWidth / 2,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 56, 30, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Everything not saved will be lost.",
                                style: CVUFont.headline2,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "These are your personal Crypto Keys. Save them in a safe place.",
                                style: CVUFont.bodyText2,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "You will need them to log into your account.",
                                style: CVUFont.bodyText2,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "And we’re so secure that if you lose them, it’s lost forever (with your data!).",
                                style: CVUFont.bodyText2.copyWith(color: Color(0xffFE570F)),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Divider(
                                height: 1,
                              ),
                              if (appController.isDevelopersMode)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Text("To use your keys locally in pymemri run:",
                                        style: CVUFont.headline3),
                                    SizedBox(
                                      height: 5,
                                    ),
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
                                      style:
                                          TextButton.styleFrom(backgroundColor: Color(0xffF0F0F0)),
                                      child: Text(
                                        "Copy",
                                        style:
                                            CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Divider(
                                      height: 1,
                                    ),
                                  ],
                                ),
                              FutureBuilder<AuthKeys>(
                                  future: Authentication.getOwnerAndDBKey(),
                                  builder: (BuildContext builder, snapshot) {
                                    if (snapshot.hasData) {
                                      ownerKey = snapshot.data!.ownerKey;
                                      dbKey = snapshot.data!.dbKey;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "your login key".toUpperCase(),
                                            style: CVUFont.smallCaps
                                                .copyWith(color: Color(0xff828282)),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            snapshot.data!.ownerKey,
                                            style: CVUFont.bodyText2
                                                .copyWith(color: Color(0xff737373)),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "your password key".toUpperCase(),
                                            style: CVUFont.smallCaps
                                                .copyWith(color: Color(0xff828282)),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            snapshot.data!.dbKey,
                                            style: CVUFont.bodyText2
                                                .copyWith(color: Color(0xff737373)),
                                          ),
                                        ],
                                      );
                                    }
                                    return Empty();
                                  }),
                              SizedBox(
                                height: 45,
                              ),
                              Row(
                                children: [
                                  if (!isCopied)
                                    TextButton(
                                      onPressed: () async {
                                        Clipboard.setData(ClipboardData(
                                            text: "Login: ${ownerKey!}\nPassword: ${dbKey!}"));
                                        setState(() {
                                          isCopied = true;
                                        });
                                      },
                                      style:
                                          TextButton.styleFrom(backgroundColor: Color(0xffF0F0F0)),
                                      child: Text(
                                        "Copy keys",
                                        style:
                                            CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
                                      ),
                                    ),
                                  if (isCopied)
                                    PrimaryButton(
                                      onPressed: () async {
                                        appController.state = AppState.authenticated;
                                      },
                                      child: Text("Keys saved"),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
