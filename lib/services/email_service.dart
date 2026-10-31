import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String _senderEmail = 'axzlhng@gmail.com'; 
  static const String _senderPassword = 'trnpdxlvetamqdnq'; 
  
  static Future<bool> sendOTPEmail({
    required String recipientEmail,
    required String otp,
    required String username,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);
      
      final message = Message()
        ..from = Address(_senderEmail, 'GreenStem Car Service')
        ..recipients.add(recipientEmail)
        ..subject = 'Email Verification -GreenStem Car Service'
        ..html = _generateOTPEmailHTML(otp, username);
      
      final sendReport = await send(message, smtpServer);
      print('OTP email sent successfully to: $recipientEmail');
      print('Message sent: ${sendReport.toString()}');
      
      return true;
    } catch (e) {
      print('Failed to send OTP email: $e');
      return false;
    }
  }

  // New method for password reset emails
  static Future<bool> sendPasswordResetEmail({
    required String recipientEmail,
    required String resetLink,
    required String username,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _senderPassword);
      
      final message = Message()
        ..from = Address(_senderEmail, 'GreenStem Car Service')
        ..recipients.add(recipientEmail)
        ..subject = 'Reset Your Password - GreenStem Car Service'
        ..html = _generatePasswordResetEmailHTML(resetLink, username);
      
      final sendReport = await send(message, smtpServer);
      print('Password reset email sent successfully to: $recipientEmail');
      print('Message sent: ${sendReport.toString()}');
      
      return true;
    } catch (e) {
      print('Failed to send password reset email: $e');
      return false;
    }
  }
  
  static String _generateOTPEmailHTML(String otp, String username) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verification</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f4f4f4;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
            }
            .logo {
                font-size: 24px;
                font-weight: bold;
                color: #246BFD;
                margin-bottom: 10px;
            }
            .otp-container {
                background-color: #f8f9fa;
                border: 2px solid #246BFD;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                margin: 20px 0;
            }
            .otp-code {
                font-size: 32px;
                font-weight: bold;
                color: #246BFD;
                letter-spacing: 8px;
                font-family: 'Courier New', monospace;
            }
            .warning {
                background-color: #fff3cd;
                border: 1px solid #ffeaa7;
                border-radius: 5px;
                padding: 15px;
                margin: 20px 0;
                color: #856404;
            }
            .footer {
                text-align: center;
                margin-top: 30px;
                color: #666;
                font-size: 12px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">GreenStem Car Service</div>
                <h2>Email Verification</h2>
            </div>
            
            <p>Hello <strong>$username</strong>,</p>
            
            <p>Thank you for registering with GreenStem Car Service. To complete your registration, please use the verification code below:</p>
            
            <div class="otp-container">
                <div class="otp-code">$otp</div>
                <p><strong>Verification Code</strong></p>
            </div>
            
            <p>This code will expire in <strong>5 minutes</strong> for security reasons.</p>
            
            <div class="warning">
                <strong>⚠️ Security Notice:</strong><br>
                • Never share this code with anyone<br>
                • Our team will never ask for this code<br>
                • If you didn't request this code, please ignore this email
            </div>
            
            <p>If you have any questions, please contact our support team.</p>
            
            <p>Best regards,<br>
            <strong>GreenStem Car Service Team</strong></p>
            
            <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>© 2025 GreenStem Car Service. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // New password reset email template
  static String _generatePasswordResetEmailHTML(String resetLink, String username) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Your Password</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f4f4f4;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
            }
            .logo {
                font-size: 24px;
                font-weight: bold;
                color: #246BFD;
                margin-bottom: 10px;
            }
            .reset-button {
                display: inline-block;
                background-color: #246BFD;
                color: white;
                padding: 15px 30px;
                text-decoration: none;
                border-radius: 8px;
                font-weight: bold;
                margin: 20px 0;
                text-align: center;
            }
            .reset-button:hover {
                background-color: #1a5bb8;
            }
            .warning {
                background-color: #fff3cd;
                border: 1px solid #ffeaa7;
                border-radius: 5px;
                padding: 15px;
                margin: 20px 0;
                color: #856404;
            }
            .footer {
                text-align: center;
                margin-top: 30px;
                color: #666;
                font-size: 12px;
            }
            .link-text {
                word-break: break-all;
                color: #246BFD;
                text-decoration: none;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">GreenStem Car Service</div>
                <h2>Reset Your Password</h2>
            </div>
            
            <p>Hello,</p>
            
            <p>Follow this link to reset your %APP_NAME% password for your %EMAIL% account.</p>
            
            <div style="text-align: center;">
                <a href="%LINK%" class="reset-button">Reset Password</a>
            </div>
            
            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
            <p><a href="%LINK%" class="link-text">%LINK%</a></p>
            
            <p>This link will expire in <strong>1 hour</strong> for security reasons.</p>
            
            <div class="warning">
                <strong>⚠️ Security Notice:</strong><br>
                • This link is only valid for 1 hour<br>
                • If you didn't request this password reset, please ignore this email<br>
                • Never share this link with anyone<br>
                • Our team will never ask for your password
            </div>
            
            <p>If you didn't ask to reset your password, you can ignore this email.</p>
            
            <p>Thanks,</p>
            <p>Your %APP_NAME% team</p>
            
            <div class="footer">
                <p>This is an automated email. Please do not reply to this message.</p>
                <p>© 2025 GreenStem Car Service. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
  
  static bool isConfigured() {
    return _senderEmail != 'your-email@gmail.com' && 
           _senderPassword != 'your-app-password';
  }
  
  static String getConfigurationStatus() {
    if (isConfigured()) {
      return 'Email service is properly configured';
    } else {
      return 'Email service needs configuration. Please update sender email and password in email_service.dart';
    }
  }
}
