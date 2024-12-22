import '../models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<AuthResponseModel> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? role = prefs.getInt('role');

    if (role == null) {
      await prefs.setInt('role', UserRole.anonymous.index);
      await prefs.setBool('isAuthorized', false);
      await prefs.setString('login', '');
      await prefs.setString('jwtToken', '');

      return emptyAuthModel;
    }

    bool? isAuthorized = prefs.getBool('isAuthorized');
    String? login = prefs.getString('login');
    String? jwtToken = prefs.getString('jwtToken');

    return AuthResponseModel(
        jwtToken: jwtToken!,
        login: login!,
        role: UserRole.values[role],
        isAuthorized: isAuthorized!
    );
  }

  static Future<void> login(AuthResponseModel model) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('role', model.role.index);
    await prefs.setBool('isAuthorized', true);
    await prefs.setString('login', model.login);
    await prefs.setString('jwtToken', model.jwtToken);
  }

  static Future<AuthResponseModel> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('role', UserRole.anonymous.index);
    await prefs.setBool('isAuthorized', false);
    await prefs.setString('login', '');
    await prefs.setString('jwtToken', '');

    return emptyAuthModel;
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('jwtToken');
  }
}

AuthResponseModel emptyAuthModel =
  AuthResponseModel(
    jwtToken: '',
    login: '',
    role: UserRole.anonymous,
    isAuthorized: false
);