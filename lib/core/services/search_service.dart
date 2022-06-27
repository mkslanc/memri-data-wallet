import 'package:memri/core/apis/search_api.dart';
import 'package:memri/core/services/api_service.dart';

class SearchService extends ApiService<SearchAPI> {
  SearchService() : super(api: SearchAPI());
}
