import 'package:memri/core/apis/base_api.dart';

class ApiService<T extends BaseAPI> {
  final T api;

  ApiService({required this.api});
}
