/// This type holds all the details required to connect to the pod and authenticate for a request
class PodConfig {
  final String baseUrl;
  final String scheme;
  final String host;
  final int port;
  final String apiVersion;
  final String ownerKey;
  final String databaseKey;

  PodConfig({
    this.baseUrl = 'http://localhost:3030',
    this.scheme = "http",
    this.host = "localhost",
    this.port = 3030,
    this.apiVersion = "v5",
    this.ownerKey = "ownerKeyHere",
    this.databaseKey = "databaseKeyHere",
  });
}
