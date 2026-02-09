import 'package:get/get.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/register_view.dart';
import '../modules/home/home_view.dart';
import '../modules/profile/edit_profile_view.dart';
import '../modules/profile/profile_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => ProfileView(),
    ),

    GetPage(
      name: Routes.editProfile,
      page: () => EditProfileView(),
    ),
  ];
}
