import 'PodAPIConnectionDetails.dart';

/// A type representing the most common `post` body for pod API requests.
/// This typically includes a database key, and a payload (different for each API endpoints)
class PodAPIRequestBody<Payload> {
  Map<String, String> auth;
  Payload payload;

  PodAPIRequestBody({required PodAPIConnectionDetails connectionConfig, required this.payload})
      : auth = {
          "type": "ClientAuth",
          "databaseKey": connectionConfig.databaseKey
        }; //TODO: change to pair, when encrypt will be implemented

  Map toJson() => {'auth': auth, 'payload': payload};
}

/// A namespace for types representing Pod API payloads. Refer to pod API documentation for expected payloads for each API.
abstract class PodAPIPayload {
  Map<String, dynamic> toJson() => {};
}

class PodAPIPayloadEmptyPayload extends PodAPIPayload {}

class PodAPIPayloadFileSHA extends PodAPIPayload {
  String sha;

  PodAPIPayloadFileSHA(this.sha);

  toJson() => {
        'sha': sha,
      };
}

class PodAPIPayloadItemId extends PodAPIPayload {
  String uid;

  PodAPIPayloadItemId(this.uid);

  toJson() => {
        'uid': uid,
      };
}

class PodAPIPayloadItemUIDList extends PodAPIPayload {
  Set<String> uids;

  PodAPIPayloadItemUIDList(this.uids);

  toJson() => {
        'uids': uids,
      };
}

class PodAPIPayloadItemUIDWithServicePayload extends PodAPIPayload {
  String uid;
  PodAPIPayloadServicePayload servicePayload;

  PodAPIPayloadItemUIDWithServicePayload({required this.uid, required this.servicePayload});

  toJson() => {'uid': uid, 'servicePayload': servicePayload};
}

/// Some of the pod APIs require a `servicePayload` included in the main payload
class PodAPIPayloadServicePayload extends PodAPIPayload {
  String databaseKey;
  String ownerKey;

  PodAPIPayloadServicePayload(PodAPIConnectionDetails connectionConfig)
      : databaseKey = connectionConfig.databaseKey,
        ownerKey = connectionConfig.ownerKey;

  toJson() => {
        'databaseKey': databaseKey,
        'ownerKey': ownerKey,
      };
}

class PodAPIPayloadBulkAction extends PodAPIPayload {
  List<Map<String, dynamic>> createItems;
  List<Map<String, dynamic>> updateItems;
  List<Map<String, dynamic>> createEdges;
  List<String> deleteItems;

  PodAPIPayloadBulkAction(
      {required this.createItems,
      required this.updateItems,
      required this.deleteItems,
      required this.createEdges});

  toJson() => {
        'createItems': createItems,
        'updateItems': updateItems,
        'deleteItems': deleteItems,
        'createEdges': createEdges
      };
}
