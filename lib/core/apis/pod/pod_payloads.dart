import '../../models/pod/pod_config.dart';

/// A type representing the most common `post` body for pod API requests.
/// This typically includes a database key, and a payload (different for each API endpoints)
class PodRequestBody<Payload> {
  Map<String, String> auth;
  Payload payload;

  PodRequestBody({required PodConfig connectionConfig, required this.payload})
      : auth = {
          "type": "ClientAuth",
          "databaseKey": connectionConfig.databaseKey
        };

  Map toJson() => {'auth': auth, 'payload': payload};
}

/// A namespace for types representing Pod API payloads. Refer to pod API documentation for expected payloads for each API.
abstract class PodPayload {
  Map<String, dynamic> toJson() => {};
}

class SchemaMeta extends PodPayload {
  String name;
  String url;
  String version;

  SchemaMeta(this.name, this.url, this.version);

  SchemaMeta.fromJson(Map<String, dynamic> meta)
      : name = meta['name'],
        url = meta['url'],
        version = meta['version'];

  @override
  toJson() => {'name': name, 'url': url, 'version': version};
}

class PodPayloadEmptyPayload extends PodPayload {}

class PodPayloadFileSHA extends PodPayload {
  String sha256;

  PodPayloadFileSHA(this.sha256);

  toJson() => {
        'sha256': sha256,
      };
}

class PodPayloadItemId extends PodPayload {
  String uid;

  PodPayloadItemId(this.uid);

  toJson() => {
        'uid': uid,
      };
}

class PodPayloadItemUIDList extends PodPayload {
  Set<String> uids;

  PodPayloadItemUIDList(this.uids);

  toJson() => {
        'uids': uids,
      };
}

class PodPayloadItemUIDWithServicePayload extends PodPayload {
  String uid;
  PodPayloadServicePayload servicePayload;

  PodPayloadItemUIDWithServicePayload(
      {required this.uid, required this.servicePayload});

  toJson() => {'uid': uid, 'servicePayload': servicePayload};
}

/// Some of the pod APIs require a `servicePayload` included in the main payload
class PodPayloadServicePayload extends PodPayload {
  String databaseKey;
  String ownerKey;

  PodPayloadServicePayload(PodConfig connectionConfig)
      : databaseKey = connectionConfig.databaseKey,
        ownerKey = connectionConfig.ownerKey;

  toJson() => {
        'databaseKey': databaseKey,
        'ownerKey': ownerKey,
      };
}

class PodPayloadBulkAction extends PodPayload {
  List<Map<String, dynamic>> createItems;
  List<Map<String, dynamic>> updateItems;
  List<Map<String, dynamic>> createEdges;
  List<String> deleteItems;

  PodPayloadBulkAction(
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

class PodPayloadCreateSchema extends PodPayload {
  SchemaMeta meta;
  Map<String, dynamic> nodes;
  Map<String, dynamic> edges;

  PodPayloadCreateSchema(this.meta, this.nodes, this.edges);

  @override
  toJson() => {
    'meta': meta.toJson(),
    'nodes': nodes,
    'edges': edges,
  };
}