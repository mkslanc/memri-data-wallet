import 'package:memri/core/apis/auth_api.dart';
import 'package:memri/core/services/api_service.dart';

class AuthService extends ApiService<AuthAPI> {
  AuthService() : super(api: AuthAPI());
}
