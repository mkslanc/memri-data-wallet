import 'dart:convert';

import 'package:http/http.dart' as http;

import 'PodAPIConnectionDetails.dart';
import 'PodAPIPayloads.dart';

enum HTTPMethod { get, post, delete, put }

extension HTTPMethodExtension on HTTPMethod {
  String get inString {
    return this.toString().toUpperCase();
  }
}

class PodAPIStandardRequest<Payload> {
  HTTPMethod method = HTTPMethod.post;
  String path;
  Map<String, String> headers;
  Payload payload;

  PodAPIStandardRequest(
      {this.method = HTTPMethod.post, required this.path, headers, required this.payload})
      : headers = headers ?? {"content-type": "application/json"};

  Future<http.Response> _executeRequest(PodAPIConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    /// For a `post` request (or other types of request) encode our payload into the body of the request.
    var body = jsonEncode(PodAPIRequestBody(connectionConfig: connectionConfig, payload: payload));
    switch (method) {
      case HTTPMethod.get:
        if (path == "version") {
          url = Uri(
              scheme: connectionConfig.scheme,
              host: connectionConfig.host,
              port: connectionConfig.port,
              path: "/$path");
        } else {
          if (payload is PodAPIPayload) {
            url = Uri(
                scheme: connectionConfig.scheme,
                host: connectionConfig.host,
                port: connectionConfig.port,
                path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path",
                queryParameters: (payload as PodAPIPayload).toJson());
          }
        }

        /// For a `get` request, encode our payload into the URL.
        return await http.get(url, headers: headers);
      case HTTPMethod.post:
        return await http.post(url, headers: headers, body: body);
      case HTTPMethod.delete:
        return await http.delete(url, headers: headers, body: body);
      case HTTPMethod.put:
        return await http.put(url, headers: headers, body: body);
    }
  }

  Future<http.Response> execute(PodAPIConnectionDetails connectionConfig) async {
    return await _executeRequest(connectionConfig);
  }

  /*static PodAPIStandardRequest getItemWithEdges(PodAPIPayload id) {
    // Note payload is just item UID (no JSON)
    var payload = id;
    return PodAPIStandardRequest(path: "get_item", payload: payload);
  }

  static PodAPIStandardRequest getItemsWithEdges(Set<String> itemIDs) {
    var payload = PodAPIPayloadItemUIDList(itemIDs);
    return PodAPIStandardRequest(path: "get_items_with_edges", payload: payload);
  }*/

  static PodAPIStandardRequest searchAction<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "search", payload: payload);
  }

  static PodAPIStandardRequest createItem(Map<String, dynamic> syncDict) {
    return PodAPIStandardRequest(path: "create_item", payload: syncDict);
  }

  static PodAPIStandardRequest updateItem(Map<String, dynamic> syncDict) {
    return PodAPIStandardRequest(path: "update_item", payload: syncDict);
  }

  static PodAPIStandardRequest deleteItem(String itemId) {
    // Note payload is just item UID (no JSON)
    return PodAPIStandardRequest(path: "delete_item", payload: itemId);
  }

  static PodAPIStandardRequest getItem<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "get_item", payload: payload);
  }

  static PodAPIStandardRequest bulkAction<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "bulk", payload: payload);
  }

  static PodAPIStandardRequest getVersion() {
    return PodAPIStandardRequest(method: HTTPMethod.get, path: "version", payload: {});
  }
}

/*struct PodAPIUploadRequest<Payload: Encodable> {
    var path: String
    var fileURL: URL
    var payload: Payload
    
    func constructRequest(connectionConfig: PodAPIConnectionDetails) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = connectionConfig.scheme
        components.host = connectionConfig.host
        components.port = connectionConfig.port
        components.path = "/\(connectionConfig.apiVersion)/\(connectionConfig.keys.ownerKey)/\(path)"
        
        guard let url = components.url else {
            throw StringError(description: "Failed to construct URL for APIRequest")
        }
        
        var request = URLRequest(url: url)
        request.method = .post
        if !(Payload.self == PodAPIPayload.EmptyPayload.self) {
            request = try URLEncodedFormParameterEncoder().encode(payload, into: request)
        }
        
        return request
    }
    
    func execute(connectionConfig: PodAPIConnectionDetails) throws -> AnyPublisher<DataResponse<Any, AFError>, Never> {
        AF.upload(fileURL, with: try constructRequest(connectionConfig: connectionConfig))
            .publishResponse(using:  JSONResponseSerializer()).eraseToAnyPublisher()
    }
    
    func execute<T: Decodable>(connectionConfig: PodAPIConnectionDetails) throws -> AnyPublisher<DataResponse<T, AFError>, Never> {
        AF.upload(fileURL, with: try constructRequest(connectionConfig: connectionConfig))
            .publishDecodable().eraseToAnyPublisher()
    }
}

struct PodAPIDownloadRequest<Payload: Encodable> {
    var path: String
    var method: HTTPMethod = .post
    var payload: Payload
    var fileUID: String
    
    var destination: DownloadRequest.Destination { { _, _ in
        let fileURL = FileStorageController.getURLForFile(withUUID: fileUID)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    }
    
    func constructRequest(connectionConfig: PodAPIConnectionDetails) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = connectionConfig.scheme
        components.host = connectionConfig.host
        components.port = connectionConfig.port
        components.path = "/\(connectionConfig.apiVersion)/\(connectionConfig.keys.ownerKey)/\(path)"
        
        guard let url = components.url else {
            throw StringError(description: "Failed to construct URL for APIRequest")
        }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.method = method
        
        switch method {
        case .get:
            /// For a `get` request, encode our payload into the URL.
            if !(Payload.self == PodAPIPayload.EmptyPayload.self) {
                request = try URLEncodedFormParameterEncoder().encode(payload, into: request)
            }
        default:
            /// For a `post` request (or other types of request) encode our payload into the body of the request.
            let body = PodAPIRequestBody(connectionConfig: connectionConfig,
                                   payload: payload)
            request = try JSONParameterEncoder().encode(body, into: request)
        }
        
        return request
    }
    
    func execute(connectionConfig: PodAPIConnectionDetails) throws -> AnyPublisher<DownloadResponse<URL, AFError>, Never> {
        AF.download(try constructRequest(connectionConfig: connectionConfig), to: destination)
            .publishURL().eraseToAnyPublisher()
    }
}*/

/*
extension PodAPIDownloadRequest {
    static func downloadFile(fileSHAHash: String, fileUID: String) -> PodAPIDownloadRequest where Payload == PodAPIPayload.FileSHA {
        PodAPIDownloadRequest(path: "get_file", payload: PodAPIPayload.FileSHA(sha: fileSHAHash), fileUID: fileUID)
    }
}

extension PodAPIUploadRequest {
    static func uploadFile(fileURL: URL, fileSHAHash: String? = nil, connectionConfig: PodAPIConnectionDetails) throws -> PodAPIUploadRequest where Payload == PodAPIPayload.EmptyPayload {
        let sha = try fileSHAHash ?? FileHelper.getSHAHash(url: fileURL)
        let path = "upload_file/\(connectionConfig.keys.dbKey)/\(sha)"
        
        return PodAPIUploadRequest(path: path, fileURL: fileURL, payload: PodAPIPayload.EmptyPayload())
    }
}*/
