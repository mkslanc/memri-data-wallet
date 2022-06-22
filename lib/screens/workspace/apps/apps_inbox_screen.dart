import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

import '../../../controllers/database_query.dart';
import '../../../controllers/file_storage/web_file_storage_controller.dart';
import '../../../core/services/database/property_database_value.dart';

class AppsInboxScreen extends StatefulWidget {
  final showMainNavigation;
  final String? importer;

  AppsInboxScreen({this.showMainNavigation = true, this.importer});

  @override
  _AppsInboxScreenState createState() => _AppsInboxScreenState();
}

class _AppsInboxScreenState extends State<AppsInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.apps,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: chats.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          setActiveChat();
                        },
                        child: Container(
                           padding: new EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  leading: CircleAvatar(
                                      radius: 16.0,
                                      backgroundImage:
                                          // chats_images.elementAt(index) == null ? Image.asset('assets/images/person.png'): Image(image: chats_images[index]!),
                                          chats_images.length > index && chats_images[index] != null
                                              ? chats_images[index]!
                                              : AssetImage(
                                                  'assets/images/person.png'),
                                      backgroundColor: Colors.transparent),
                                  title: FutureBuilder(
                                      future: chats[index].propertyValue('name'),
                                      builder: (context, value) {
                                        if (!value.hasData) return Text("");
                                        return Text(
                                            (value.data! as PropertyDatabaseValue)
                                                .value
                                                .toString(),
                                            style: TextStyle(fontSize: 13));
                                      }),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.more_horiz,
                                      color: Color(0xFFDFDEDE)))
                            ],
                          ),
                        ));
                  }),
            ),
            Expanded(
                flex: 2,
                child: ListView.builder(
                    itemCount: activeChatMessages.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              leading: CircleAvatar(
                                  child:
                                      Image.asset('assets/images/person.png'),
                                  backgroundColor: Colors.transparent),
                              title: FutureBuilder(
                                  future: activeChatMessages[index]
                                      .propertyValue('content'),
                                  builder: (context, value) {
                                    if (!value.hasData)
                                      return Text("");
                                    else {
                                      var rng = Random();
                                      var by_me = rng.nextInt(2) == 0;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding: new EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 15),
                                              child: Text(
                                                (value.data!
                                                        as PropertyDatabaseValue)
                                                    .value
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: by_me
                                                        ? Color(0xFFFBFBFB)
                                                        : Color(0xFF333333)),
                                              ),
                                              decoration: BoxDecoration(
                                                color: by_me
                                                    ? Color(0xFF4F56FE)
                                                    : Color(0xFFF8F8F8),
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10)),
                                              )),
                                        ],
                                      );
                                    }
                                  }),
                            ),
                          )
                        ],
                      );
                    })),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  List<ItemRecord> chats = [];
  List<ItemRecord> activeChatMessages = [];
  List<ImageProvider?> chats_images = [];
  late Stream result;

  Future<ImageProvider?> imageProviderFromPhoto(ItemRecord photoItem) async{
    if (photoItem.type != "Photo"){ 
      print("CCC");
      return null;
    }
    var fileItem = await photoItem.edgeItem("file");
    var fileID = (await fileItem?.propertyValue("sha256"))?.asString();
    if (fileID == null) {
      return null;
    } else {
      print("DWQG");
      String fileURL = FileStorageController.getURLForFile(fileID);
      var imageProvider = await FileStorageController.getImage(fileURL: fileURL);
      return imageProvider;
    }

  }

  void getChats() async {
    var queryDef = DatabaseQueryConfig(
        itemTypes: ["MessageChannel"], pageSize: 1000, currentPage: 0);
    result = queryDef.executeRequest(AppController.shared.databaseController);

    print("BBB");
    result.asBroadcastStream().listen((event) async {
      List<ImageProvider?> _chats_images = [];
      for (ItemRecord c in event as List<ItemRecord>) {
        var photoItem = await c.edgeItem("photo");
        _chats_images.add(photoItem == null? null :await imageProviderFromPhoto.call(photoItem));
      }
      setState(() {
        chats = event;
        chats_images = _chats_images;
        //  image: {{.sender.owner.profilePicture OR .sender.profilePicture OR "assets/images/person.png"}}
      });
    });
  }

  void setActiveChat() async {
    var queryDef = DatabaseQueryConfig(
        itemTypes: ["Message"], pageSize: 30, currentPage: 0);
    result = queryDef.executeRequest(AppController.shared.databaseController);

    print(result);
    result.asBroadcastStream().listen((event) {
      setState(() {
        activeChatMessages = event as List<ItemRecord>;
      });
    });
  }
}
