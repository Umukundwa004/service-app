import 'package:email_otp/email_otp.dart';

class EmailOtpService {
  static void configureSmtp({
    required String username,
    required String appPassword,
  }) {
    if (username.isEmpty || appPassword.isEmpty) {
      return;
    }

    EmailOTP.setSMTP(
      host: 'smtp.gmail.com',
      emailPort: EmailPort.port587,
      secureType: SecureType.tls,
      username: username,
      password: appPassword,
    );
  }

  static Future<bool> sendCode(String userEmail) async {
    return EmailOTP.sendOTP(email: userEmail);
  }

  static bool verifyCode(String userCode) {
    return EmailOTP.verifyOTP(otp: userCode);
  }
}
