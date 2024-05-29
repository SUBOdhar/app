import 'package:http/http.dart' as http;
import 'dart:convert';

class VersionService {
  final String currentVersion = 'v0.0.095'; // Example client version
  final String serverUrl =
      'https://api.svp.com.np/version-manager'; // Update with your server details

  Future<Map<String, dynamic>> checkVersion() async {
    final url = Uri.parse(serverUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'version': currentVersion}),
    );

    if (response.statusCode == 200) {
      return {'status': 'up_to_date', 'message': 'Version is up to date'};
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      return {
        'status': 'update_needed',
        'global_version': responseData['global_version'],
        'message': 'New version available: ${responseData['global_version']}'
      };
    } else {
      return {'status': 'error', 'message': 'Error checking version'};
    }
  }
}
