//  Created by T Brennan on 17/12/20.

/// This type holds all the details required to connect to the pod and authenticate for a request
class PodConnectionDetails {
  final String baseUrl;
  final String scheme;
  final String host;
  final int port;
  final String apiVersion;
  final String ownerKey;
  final String databaseKey;

  PodConnectionDetails(
      {this.baseUrl = 'http://localhost:3030',
      this.scheme = "http",
      this.host = "localhost",
      this.port = 3030,
      this.apiVersion = "v4",
      this.ownerKey = "ownerKeyHere",
      this.databaseKey = "databaseKeyHere"});
}
