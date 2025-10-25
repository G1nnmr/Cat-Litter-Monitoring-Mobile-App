// lib/email_alert.dart
import 'package:http/http.dart' as http;

class EmailAlertService {
  static Future<bool> sendAlert(String email) async {
    final url = Uri.parse('http://10.195.250.63/myapp/send_alert.php');

    try {
      final response = await http.post(
        url,
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        print('Email sent: ${response.body}');
        return true;
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
