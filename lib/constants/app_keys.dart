class AppKeys {
  static final AppKeys _keys = AppKeys._internal();

  factory AppKeys() => _keys;

  AppKeys._internal();

  final String ownerKey = 'owner_key';
  final String dbKey = 'database_key';
  final String podAddress = 'pod_address';
}
