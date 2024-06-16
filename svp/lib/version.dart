import 'package:http/http.dart' as http;
import 'dart:convert';

class VersionService {
  final String currentVersion = 'v0.0.008'; // Example client version
  final String serverUrl =
      'https://api.svp.com.np/version-manager'; // Update with your server details

  Future<Map<String, dynamic>> checkVersion() async {
    final url = Uri.parse(serverUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'version': currentVersion}),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['status'] == 'up_to_date') {
      return {'status': 'up_to_date', 'message': 'Version is up to date'};
    } else if (response.statusCode == 200 &&
        responseData['status'] == 'update_needed') {
      return {
        'status': 'update_needed',
        'global_version': responseData['global_version'],
        'url': responseData['url'],
        'message': 'New version available: ${responseData['global_version']}'
      };
    } else {
      return {'status': 'error', 'message': 'Error checking version'};
    }
  }
}
