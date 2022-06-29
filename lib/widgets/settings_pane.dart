import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/core/controllers/address_book_controller.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/utilities/factory_reset.dart';
import 'package:memri/widgets/space.dart';

class SettingsPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: app.colors.brandBlack,
      padding: const EdgeInsets.fromLTRB(30, 50, 25, 25),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: space(
                15,
                [
                  SizedBox(
                    height: 50,
                  ),
                  Text("Connected accounts",
                      style: TextStyle(
                          color: app.colors.brandWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("WhatsApp",
                              style: CVUFont.buttonLabel
                                  .copyWith(color: Colors.white)),
                          Text("Contacts, Messages",
                              style: CVUFont.bodyText2
                                  .copyWith(color: app.colors.brandGreyText)),
                        ],
                      )),
                      TextButton(
                          onPressed: null,
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(
                                  color: app.colors.brandBlueText,
                                  fontSize: 16),
                              backgroundColor: app.colors.brandWhite),
                          child: Text("Connect")),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: Text(
                              "I consent to sharing my usage data for the purpose of enhancing user experience.",
                              style: CVUFont.buttonLabel
                                  .copyWith(color: Colors.white))),
                      Switch(
                        value: false,
                        onChanged: null,
                      )
                    ],
                  ),
                  Text(
                      "When this setting is on, you consent for memri to report information on app usage (for example, which of the features are most frequently used). Learn more.",
                      style: CVUFont.bodyText2
                          .copyWith(color: app.colors.brandGreyText)),
                  TextButton(
                      onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Contacts importing'),
                              content: const Text(
                                  'Do you want to import contacts from Android Contacts?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    await AddressBookController.sync();
                                    Navigator.pop(context, 'OK');
                                  },
                                  child: const Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                      child: Text("Import contacts",
                          style: TextStyle(
                              color: app.colors.brandWhite, fontSize: 18))),
                  TextButton(
                      onPressed: null,
                      child: Text("Privacy and security",
                          style: TextStyle(
                              color: app.colors.brandGreyText, fontSize: 18))),
                  TextButton(
                      onPressed: null,
                      child: Text("Report a bug",
                          style: TextStyle(
                              color: app.colors.brandGreyText, fontSize: 18))),
                  TextButton(
                      onPressed: null,
                      child: Text("Request a feature",
                          style: TextStyle(
                              color: app.colors.brandGreyText, fontSize: 18))),
                  TextButton(
                      onPressed: () => factoryReset(context),
                      child: Text("Factory reset",
                          style: TextStyle(
                              color: app.colors.brandWhite, fontSize: 18)))
                ],
                Axis.vertical),
          ),
          Positioned(
              right: 0,
              child: FloatingActionButton(
                  backgroundColor: app.colors.brandWhite,
                  child: Icon(Icons.close, color: app.colors.blue),
                  onPressed: () => Navigator.of(context).pop()))
        ],
      ),
    );
  }
}
