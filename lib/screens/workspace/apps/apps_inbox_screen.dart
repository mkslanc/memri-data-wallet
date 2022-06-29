import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

import '../../../controllers/file_storage/web_file_storage_controller.dart';
import '../../../core/apis/pod/item.dart';
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
                          String? chatID = chats[index].get("id")?.toString();
                          setActiveChat(chatID: chatID!);
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
                                          chatImages.length > index &&
                                                  chatImages[index] != null
                                              ? chatImages[index]!
                                              : AssetImage(
                                                  'assets/images/person.png'),
                                      backgroundColor: Colors.transparent),
                                  title: Text(chats[index].get("name") != null
                                      ? chats[index].get("name")
                                      : ""),
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
                              title: Builder(builder: (context) {
                                var value = activeChatMessages[index]
                                    .get('content')
                                    ?.toString();
                                if (value == null) {
                                  return Text("");
                                } else {
                                  bool by_me = activeChatMessages[index]
                                          .edgeItem("sender")
                                          ?.get("isMe") ??
                                      false;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: new EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: Text(
                                            value,
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
                                                topRight: Radius.circular(10),
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

  List<Item> chats = [];
  List<Item> activeChatMessages = [];
  List<ImageProvider?> chatImages = [];
  StreamSubscription<List<Item>>? chatStreamSubscription;
  StreamSubscription<List<Item>>? messageStreamSubscription;

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  void dispose() {
    chatStreamSubscription?.cancel();
    messageStreamSubscription?.cancel();
    super.dispose();
  }

  Stream<List<Item>> gqlStream(String query) async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      List<Item>? items = null;
      await AppController.shared.podApi.graphql(
          query: query,
          completion: (data, error) {
            if (data != null) {
              items = data;
            }
          });
      if (items != null) {
        yield items!;
      }
    }
  }

  Future<ImageProvider?> imageProviderFromPhoto(Item photoItem) async {
    var fileItem = photoItem.edgeItem("file");
    var fileID = (await fileItem?.get("sha256"))?.toString();
    if (fileID == null) {
      return null;
    } else {
      String fileURL = FileStorageController.getURLForFile(fileID);
      var imageProvider =
          await FileStorageController.getImage(fileURL: fileURL);
      return imageProvider;
    }
  }

  void testPrint(List<Item> result) {
    print("num chats ${result.length}");
    for (Item item in result) {
      print("${item.properties}");
    }
  }

  void sortByEdgeProperty(
      {required List<Item> items,
      required String edge,
      required String property,
      required String order}) {
    if (order == "asc") {
      items.sort((a, b) {
        if (a.edgeItem(edge)?.get(property) == null) {
          return 1;
        } else if (b.edgeItem(edge)?.get(property) == null) {
          return -1;
        }
        return a
            .edgeItem(edge)!
            .get(property)
            .compareTo(b.edgeItem(edge)!.get(property));
      });
    } else {
      items.sort((b, a) {
        if (a.edgeItem(edge)?.get(property) == null) {
          return 1;
        } else if (b.edgeItem(edge)?.get(property) == null) {
          return -1;
        }
        return a
            .edgeItem(edge)!
            .get(property)
            .compareTo(b.edgeItem(edge)!.get(property));
      });
    }
  }

  void getChats() async {
    var query = '''
      query {
        MessageChannel (limit: 1000) {
          id
          name
          photo {
            id
            file {
              sha256
            }
          }
          ~messageChannel (limit: 1, order_desc: dateSent) {
            dateSent
          }
        }
      }''';

    chatStreamSubscription = gqlStream(query).listen((res) {
      // for (var item in res) {
      //   print(item.edgeItem("~messageChannel")?.get("dateSent"));
      // }
      sortByEdgeProperty(
          items: res,
          edge: "~messageChannel",
          property: "dateSent",
          order: "desc");
      setState(() {
        chats = res;
      });
    });
  }

  void setActiveChat({required String chatID, limit = 30, offset = 0}) async {
    // Reset active messages while waiting for query
    messageStreamSubscription?.cancel();
    setState(() {
      activeChatMessages = [];
    });

    String query = '''
      query {
        MessageChannel (filter: {id: {eq: "$chatID"}}) {
          id
          ~messageChannel (limit: $limit, offset: $offset, order_desc: dateSent) {
            dateSent
            content
            sender {
              displayName
              isMe
            }
          }
        }
      }
    ''';

    messageStreamSubscription = gqlStream(query).listen((result) {
      List<Item> messages = [];
      if (result.length > 0) {
        var _messages = result[0].getEdges("~messageChannel")?.targets;
        if (_messages != null) {
          messages = _messages;
        }
      }

      setState(() {
        activeChatMessages = messages;
      });
    });
  }
}
