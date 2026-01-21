import 'dart:async';
import 'dart:io';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserErrorMessage {
  static const String generic =
      'Something went wrong. Please try again.';

  static String from(
    Object? error, {
    String fallback = generic,
  }) {
    if (error == null) return fallback;

    if (error is StripeException) {
      return _fromStripe(error);
    }

    if (error is AuthException) {
      return _fromAuth(error);
    }

    if (error is PostgrestException) {
      return _fromPostgrest(error, fallback: fallback);
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is SocketException) {
      return 'Network error. Please check your connection.';
    }

    if (error is HttpException) {
      return 'We could not reach the server. Please try again.';
    }

    if (error is FormatException) {
      return 'Unexpected response. Please try again.';
    }

    if (error is String) {
      return _sanitizeString(error, fallback: fallback);
    }

    return fallback;
  }

  static String _fromAuth(AuthException error) {
    final message = error.message.toLowerCase();
    final isOtpRelated =
        message.contains('otp') ||
        message.contains('token') ||
        message.contains('code');

    if (message.contains('expired') && isOtpRelated) {
      return 'Verification code expired. Please request a new one.';
    }
    if (isOtpRelated && message.contains('invalid')) {
      return 'Invalid code. Please try again.';
    }
    if (message.contains('too many') ||
        message.contains('rate') ||
        message.contains('limit')) {
      return 'Too many attempts. Please try again later.';
    }
    if (message.contains('already') && message.contains('registered')) {
      return 'An account already exists for this email.';
    }
    if (message.contains('already') && message.contains('exists')) {
      return 'An account already exists for this email.';
    }
    if (message.contains('email') && message.contains('format')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('invalid') &&
        (message.contains('login') || message.contains('password'))) {
      return 'Incorrect email or password.';
    }
    if (message.contains('invalid login') || message.contains('credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('password')) {
      return 'Password does not meet requirements.';
    }
    return 'Unable to sign in. Please try again.';
  }

  static String _fromStripe(StripeException error) {
    final code = error.error.stripeErrorCode?.toLowerCase();
    final localized = error.error.localizedMessage;
    
    if (localized != null && localized.isNotEmpty) {
      return localized;
    }

    switch (code) {
      case 'card_declined':
        return 'Your card was declined. Please try another card.';
      case 'expired_card':
        return 'This card is expired. Please use a different card.';
      case 'incorrect_cvc':
        return 'The card security code is incorrect.';
      case 'incorrect_number':
        return 'The card number is invalid.';
      case 'processing_error':
        return 'Payment could not be processed. Please try again.';
      case 'insufficient_funds':
        return 'Insufficient funds on this card.';
      case 'invalid_expiry_month':
      case 'invalid_expiry_year':
        return 'The card expiration date is invalid.';
      case 'invalid_cvc':
        return 'The card security code is invalid.';
      case 'invalid_number':
        return 'The card number is invalid.';
      default:
        return error.error.message ?? 'Payment failed. Please try another card.';
    }
  }

  static String _fromPostgrest(
    PostgrestException error, {
    required String fallback,
  }) {
    final message = error.message.toLowerCase();
    if (message.contains('duplicate') ||
        message.contains('unique') ||
        message.contains('already exists')) {
      return 'This information is already in use.';
    }
    return fallback;
  }

  static String _sanitizeString(
    String message, {
    required String fallback,
  }) {
    final cleaned =
        message.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

    if (cleaned.isEmpty) return fallback;
    if (_looksTechnical(cleaned)) return fallback;

    return cleaned;
  }

  static bool _looksTechnical(String message) {
    final lower = message.toLowerCase();
    const technicalTokens = [
      'exception',
      'postgrest',
      'supabase',
      'stripe',
      'stack',
      'trace',
      'http',
      'socket',
      'timeout',
      'json',
      'rpc',
      'sql',
      'jwt',
      'typeerror',
      'null',
    ];

    if (technicalTokens.any(lower.contains)) return true;
    if (message.length > 160) return true;
    if (RegExp(r'[\{\}\[\]<>]').hasMatch(message)) return true;
    if (RegExp(r'https?://').hasMatch(message)) return true;

    return false;
  }
}
