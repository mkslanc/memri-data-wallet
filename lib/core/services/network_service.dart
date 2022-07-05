import 'package:memri/constants/app_logger.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NetworkService {
  Future<void> openLink(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(url)
        : AppLogger.err('Could not launch $url');
  }
}
